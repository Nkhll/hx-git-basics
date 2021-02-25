/**************************************************************************************************
Author: Nikhil Kumar Srivastava
Company: Hexaware Technologies
Description:  Class for all Case business for Lease and Renewal
====================================================================================================
====================================================================================================
TestClass: APCHA_CaseBusinessForLeaseAndRenewalTest
Code Coverage: 
====================================================================================================
====================================================================================================
History
<Version>   <Date>             <Author Name>                <Brief description of change > 
1.0 -       02/25/2020          Nikhil Kumar Srivastava      Initial Creation   
***************************************************************************************************/
public without sharing class APCHA_CaseBusinessForLeaseAndRenewal {
    
    /**
    * Method :createUpdateLeaseRenawalCaseRecord
    * @author Nikhil Kumar Srivastava
    * @Param Case New List
    * @Param Case Old Map
    */
    public static void createUpdateLeaseRenawalCaseRecord(List<Case> newCaseList, Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap) {
        if(newCaseList == null){
            return;
        }
       // Set<Id> applicantIdsSet = new Set<Id>();
        Map<Id, List<Case>> unitIdToListOfCaseMap = new Map<Id, List<Case>>();
        //If Case is for Rental Ownership lease won't be created
        for(Case caseRec : [SELECT Id, 
                            RecordTypeId, Status, APCHA_QUAL_Application_Status__c,APCHA_QUAL_Application_Type__c ,
                            APCHA_QUAL_Primary_Applicant_Name__c, APCHA_QUAL_Primary_Applicant_Name__r.PersonContactId, 
                            APCHA_QUAL_Secondary_Applicant_Name__c,APCHA_QUAL_Secondary_Applicant_Name__r.PersonContactId, 
                            APCHA_QUAL_3rd_Applicant_Name__c, APCHA_QUAL_3rd_Applicant_Name__r.PersonContactId, 
                            APCHA_QUAL_4th_Applicant_Name__c, APCHA_QUAL_4th_Applicant_Name__r.PersonContactId,
                            APCHA_QUAL_Listing_Advertisement__c,APCHA_QUAL_Listing_Advertisement__r.APCHA_Listing_Unit_House__c 
                            FROM CASE 
                            WHERE Id IN: newCaseList AND RecordTypeId =: APCHA_Constants.QUALIFICATION_RT]) { 

            if((oldCaseMap == NULL || (newCaseMap.get(caseRec.Id).APCHA_QUAL_Application_Status__c != oldCaseMap.get(caseRec.Id).APCHA_QUAL_Application_Status__c)) 
                && (newCaseMap.get(caseRec.Id).APCHA_QUAL_Application_Status__c == APCHA_Constants.CASE_STATUS_APPROVED)) {
                if(caseRec.APCHA_QUAL_Application_Type__c != APCHA_Constants.CASE_APPLICATION_TYPE_SALE_OWNERSHIP && 
                    caseRec.APCHA_QUAL_Listing_Advertisement__c != NULL && caseRec.APCHA_QUAL_Listing_Advertisement__r.APCHA_Listing_Unit_House__c != NULL) {
                            
                        if(!unitIdToListOfCaseMap.containsKey(caseRec.APCHA_QUAL_Listing_Advertisement__r.APCHA_Listing_Unit_House__c)) {
                            unitIdToListOfCaseMap.put(caseRec.APCHA_QUAL_Listing_Advertisement__r.APCHA_Listing_Unit_House__c, new List<Case>());
                        }
                        unitIdToListOfCaseMap.get(caseRec.APCHA_QUAL_Listing_Advertisement__r.APCHA_Listing_Unit_House__c).add(caseRec);
                        System.debug('unitIdToListOfCaseMap ' + unitIdToListOfCaseMap);
                    } 
                }
            }
        //Search for Active, Approved & In-Progress leases with these units
        Map<Id, Case> caseIdToActiveLeaseCaseMap = new Map<Id, Case>([  Select Id, APCHA_Unit_Property__c FROM Case WHERE
                                                                        APCHA_Unit_Property__c IN :unitIdToListOfCaseMap.keyset() AND 
                                                                        RecordTypeId = :APCHA_Constants.LEASERENEWALCASE_RT 
                                                                        AND Status = :APCHA_Constants.CASE_STATUS_ACTIVE]);
        System.debug('caseIdToActiveLeaseCaseMap ' + caseIdToActiveLeaseCaseMap);
        /**
         * Creating a map with unitId to Active Lease.
         */
        Map<Id, List<Case>> unitIdToListOfActiveLeaseMap = new Map<Id, List<Case>>();
        if(!unitIdToListOfCaseMap.isEmpty()) {
            for(Id unitIdRec : unitIdToListOfCaseMap.keySet()) {
                if(!caseIdToActiveLeaseCaseMap.isEmpty()) { 
                    for(Id caseIdRec : caseIdToActiveLeaseCaseMap.keySet()) {
                        if(!unitIdToListOfActiveLeaseMap.containsKey(unitIdRec)) {
                            unitIdToListOfActiveLeaseMap.put(unitIdRec, new List<Case>());
                        }
                        unitIdToListOfActiveLeaseMap.get(unitIdRec).add(caseIdToActiveLeaseCaseMap.get(caseIdRec));
                    }
                } else {
                    if(!unitIdToListOfActiveLeaseMap.containsKey(unitIdRec)) {
                        unitIdToListOfActiveLeaseMap.put(unitIdRec, new List<Case>());
                    }
                }        
            }    
        }
        system.debug('unitIdToListOfActiveLeaseMap Last ' + unitIdToListOfActiveLeaseMap);
        /**
         * Creating a map with UnitId to first occurence Lease
         * Commented as previously we're picking the Active Lease only under assumption that, there can only
         * be one Active Lease at a time. 
         */
        Map<Id, Case> unitIdToLeaseToUpsertMap = new Map<Id, Case>();
        if(!unitIdToListOfActiveLeaseMap.isEmpty()) {
            for(Id unitIdRec: unitIdToListOfActiveLeaseMap.keySet()) {
                Case caseRec = new Case();
                if(unitIdToListOfActiveLeaseMap.get(unitIdRec).size() > 0) {
                    caseRec = unitIdToListOfActiveLeaseMap.get(unitIdRec)[0];
                }
                if(!unitIdToLeaseToUpsertMap.containsKey(unitIdRec)) {
                    unitIdToLeaseToUpsertMap.put(unitIdRec, new Case());
                }
                unitIdToLeaseToUpsertMap.put(unitIdRec, caseRec);
            }
        }    
        System.debug('unitIdToLeaseToUpsertMap' + unitIdToLeaseToUpsertMap);

        /**
         *  UnitIdToListLeaseMap - includes unit to Lease line items to be created with these applicant
         */
    
        Map<Id, List<APCHA_Lease_Line__c>> unitIdToListLeaseLineMap = new Map<Id, List<APCHA_Lease_Line__c>>();
        if(!unitIdToListOfCaseMap.isEmpty()) {
            for(Id unitIdRec : unitIdToListOfCaseMap.keySet()) {
                for(Case caseRec : unitIdToListOfCaseMap.get(unitIdRec)) {
                    if(!unitIdToListLeaseLineMap.containsKey(unitIdRec)) {
                        unitIdToListLeaseLineMap.put(unitIdRec, new List<APCHA_Lease_Line__c>());
                    }
                    if(caseRec.APCHA_QUAL_Primary_Applicant_Name__c != null)//use current tennant flag
                        unitIdToListLeaseLineMap.get(unitIdRec).add(new APCHA_Lease_Line__c(APCHA_Account__c = caseRec.APCHA_QUAL_Primary_Applicant_Name__c));
                    if(caseRec.APCHA_QUAL_Secondary_Applicant_Name__c != null)
                        unitIdToListLeaseLineMap.get(unitIdRec).add(new APCHA_Lease_Line__c(APCHA_Account__c = caseRec.APCHA_QUAL_Secondary_Applicant_Name__c));
                    if(caseRec.APCHA_QUAL_3rd_Applicant_Name__c != null)
                        unitIdToListLeaseLineMap.get(unitIdRec).add(new APCHA_Lease_Line__c(APCHA_Account__c = caseRec.APCHA_QUAL_3rd_Applicant_Name__c));
                    if(caseRec.APCHA_QUAL_4th_Applicant_Name__c != null)
                        unitIdToListLeaseLineMap.get(unitIdRec).add(new APCHA_Lease_Line__c(APCHA_Account__c = caseRec.APCHA_QUAL_4th_Applicant_Name__c));
                }
            }    
        }
        system.debug('unitIdToListLeaseLineMap' + unitIdToListLeaseLineMap);

        /**
         * Creating a map with UnitId to Temp Single Lease(Case) with its Lease lines as applicants on the applications  
         * Assumption : One unit will have only one Active Lease.
         */ 
        //Map<Id, Case> unitIdToTempLeaseCaseMap = new Map<Id, Case>();
        List<Case> leaseCaseRecordToInsert = new List<Case>();
        List<Id> unitIdWithNoLease = new List<Id>();
        List<APCHA_Lease_Line__c> leaseLineWithLeaseToInsert = new List<APCHA_Lease_Line__c>();
        List<APCHA_Lease_Line__c> leaseLineWithNoLeaseToInsert = new List<APCHA_Lease_Line__c>();

        if(!unitIdToLeaseToUpsertMap.isEmpty()) {
            for(Id unitIdRec : unitIdToLeaseToUpsertMap.keySet()) { 
                Case leaseRec = new Case();
                //If Lease already exists
                if(unitIdToLeaseToUpsertMap.get(unitIdRec) != NULL && unitIdToLeaseToUpsertMap.get(unitIdRec).Id != NULL) { //check for this
                    leaseRec.Id = unitIdToLeaseToUpsertMap.get(unitIdRec).Id;
                    for(APCHA_Lease_Line__c leaseLiRec : unitIdToListLeaseLineMap.get(unitIdRec)) {
                        System.debug('Before ID 142');
                        leaseLiRec.APCHA_Lease__c = leaseRec.Id;
                        leaseLineWithLeaseToInsert.add(leaseLiRec);
                    } 
                } else {
                    //Create a new Lease
                    leaseRec.RecordTypeId = APCHA_Constants.LEASERENEWALCASE_RT;
                    leaseRec.Status = 'Active';
                    leaseRec.APCHA_Unit_Property__c = unitIdRec;
                    leaseCaseRecordToInsert.add(leaseRec);
                }
                unitIdWithNoLease.add(unitIdRec);
            }
        }  
        System.debug(leaseCaseRecordToInsert);
        System.debug(leaseLineWithLeaseToInsert);
        
        if(APCHA_CaseTriggerHandler.runOnceFlag) {
            
            if(leaseCaseRecordToInsert.size() > 0) {
                APCHA_CaseTriggerHandler.runOnceFlag = false;
                Insert leaseCaseRecordToInsert;
            }
            if(unitIdWithNoLease.size() > 0) {
                //List<Case> leaseCaseRecord = Select 
                for(Id unitIdRec: unitIdWithNoLease) {
                    for(Case caseRec: leaseCaseRecordToInsert) {
                        if(caseRec.APCHA_Unit_Property__c == unitIdRec) {
                            System.debug('unitIdToListLeaseLineMap.get(unitIdRec)' + unitIdToListLeaseLineMap.get(unitIdRec));
                            for(APCHA_Lease_Line__c leaseLiRec : unitIdToListLeaseLineMap.get(unitIdRec)) {
                                leaseLiRec.APCHA_Lease__c = caseRec.Id;
                                leaseLineWithNoLeaseToInsert.add(leaseLiRec);
                            } 
                        }
                    }
                }
            } 
            if(leaseLineWithLeaseToInsert.size() > 0 || leaseLineWithNoLeaseToInsert.size() > 0) {
                Insert leaseLineWithLeaseToInsert;
                Insert leaseLineWithNoLeaseToInsert;
            }  
        }
    }//End of funtion()
    //Application -> approved
    //lease status - active
    //Add new Line if not Lease type 
    //checkActiveLeaseontheunit
    
}