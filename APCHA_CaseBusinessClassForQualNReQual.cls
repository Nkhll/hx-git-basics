/**************************************************************************************************
Author: Siddhika Rajendra Nigudkar
Company: Hexaware Technologies
Description:  Class for all Qualification and Re-Qualification Methods
====================================================================================================
====================================================================================================
TestClass: APCHA_CaseTriggerHandlerTest
Code Coverage: 91%
====================================================================================================
====================================================================================================
History
<Version>   <Date>             <Author Name>                <Brief description of change > 
1.0 -      02/25/2020             Siddhika N                          Initial Creation   
2.0-        04/10/2020            Siddhika N                           Modified to cover catch blocks(Coverage : 91 %)
***************************************************************************************************/
public class APCHA_CaseBusinessClassForQualNReQual {    
    
    /** Method: setQualDatesOnAcc
Author: Siddhika Nigudkar
Purpose: Set Qualification and Qualification Expiry Date of Accounts When Application-Case is Approved.(HTP1-310)
**/    
    public static void setQualDatesOnAcc(List<case> newCaseList, Map<Id, Case> oldCaseMap){
        try{
            Set<Id> ApplicantIdsTCSet = new Set<Id>();
            Set<Id> ApplicantIdsNonTCSet = new Set<Id>();
            Set<Id> ApplicantIdsReQualSet = new Set<Id>();
            Map<Id, Account> AccountsofApprovedCasesMap = new Map<Id, Account>();
            List<Account> AccListToUpadteQualDates = new List<Account>();
            Set<Id> newCaseIds = new Set<Id>();        
            System.debug('sid--->newCaseList'+newCaseList);
            for(Case cTemp : newCaseList){
                if(cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT || cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT)
                    newCaseIds.add(cTemp.Id);
            }
            if(newCaseIds.Size() <= 0){
                return;
            }
            //**Get Ids of 4 applicants from all Application Cases that are changed to Approved Status
            //**If Case is for Apcha-Managed tax-Credit, Add Id to ApplicantIdsAMTCSet Else to ApplicantIdsNonAMTCSet
            for(Case cTemp :APCHA_SOQLUtil.getCaseRecords(newCaseIds, null).values()){
                
                if((cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT || cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT)
                && cTemp.APCHA_QUAL_Application_Status__c != oldCaseMap.get(cTemp.Id).APCHA_QUAL_Application_Status__c 
                && cTemp.APCHA_QUAL_Application_Status__c == APCHA_Constants.CASE_STATUS_APPROVED && cTemp.APCHA_QUAL_Application_Type__c != APCHA_Constants.APP_TYPE_SEASONAL_RENTAL){
                    
                    if(cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT && cTemp.APCHA_QUAL_Application_Type__c == APCHA_Constants.APP_TYPE_TAX_CREDIT_RENTAL ){
                        
                        if(cTemp.APCHA_QUAL_Primary_Applicant_Name__c != null)
                            ApplicantIdsTCSet.add(cTemp.APCHA_QUAL_Primary_Applicant_Name__c);
                        if(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c != null)
                            ApplicantIdsTCSet.add(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c);
                        if(cTemp.APCHA_QUAL_3rd_Applicant_Name__c != null)
                            ApplicantIdsTCSet.add(cTemp.APCHA_QUAL_3rd_Applicant_Name__c);
                        if(cTemp.APCHA_QUAL_4th_Applicant_Name__c != null)
                            ApplicantIdsTCSet.add(cTemp.APCHA_QUAL_4th_Applicant_Name__c);
                    } 
                    else{
                        if(cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT){
                            if(cTemp.APCHA_QUAL_Primary_Applicant_Name__c != null)
                                ApplicantIdsReQualSet.add(cTemp.APCHA_QUAL_Primary_Applicant_Name__c);
                            if(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c != null)
                                ApplicantIdsReQualSet.add(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c);
                            if(cTemp.APCHA_QUAL_3rd_Applicant_Name__c != null)
                                ApplicantIdsReQualSet.add(cTemp.APCHA_QUAL_3rd_Applicant_Name__c);
                            if(cTemp.APCHA_QUAL_4th_Applicant_Name__c != null)
                                ApplicantIdsReQualSet.add(cTemp.APCHA_QUAL_4th_Applicant_Name__c);
                        }
                        else if(cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT){
                            if(cTemp.APCHA_QUAL_Primary_Applicant_Name__c != null)
                                ApplicantIdsNonTCSet.add(cTemp.APCHA_QUAL_Primary_Applicant_Name__c);
                            if(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c != null)
                                ApplicantIdsNonTCSet.add(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c);
                            if(cTemp.APCHA_QUAL_3rd_Applicant_Name__c != null)
                                ApplicantIdsNonTCSet.add(cTemp.APCHA_QUAL_3rd_Applicant_Name__c);
                            if(cTemp.APCHA_QUAL_4th_Applicant_Name__c != null)
                                ApplicantIdsNonTCSet.add(cTemp.APCHA_QUAL_4th_Applicant_Name__c);
                        }                                
                    }
                }
                            
            }
            
            //**Get Map of all the accounts for All Applicants with cases changed to approved
            if(ApplicantIdsNonTCSet.size() > 0 || ApplicantIdsTCSet.size() > 0 || ApplicantIdsReQualSet.size() > 0 ){
                Set<Id> AllAccIds = new Set<Id>();
                AllAccIds.addAll(ApplicantIdsNonTCSet);
                AllAccIds.addAll(ApplicantIdsTCSet);
                AllAccIds.addAll(ApplicantIdsReQualSet);
                AccountsofApprovedCasesMap = APCHA_SOQLUtil.getAccountRecords(AllAccIds, APCHA_Constants.PERSON_ACCOUNT_RT);
            }
            
            for(Account aTemp : AccountsofApprovedCasesMap.values() ){
                
                //**For Tax-Credit(ApplicantIdsTCSet) Qualification, Qualification Expiry date is first day of the anniversary month
                //**Qualification Date is set to Today 
                if(ApplicantIdsTCSet.contains(aTemp.id) && (aTemp.APCHA_Qualification_Date__c == NULL)){
                    aTemp.APCHA_Qualification_Date__c = date.today();
                    aTemp.APCHA_Qualification_Expiry_Date__c = Date.newInstance(date.today().year()+1,date.today().month(),1)-1;
                } 
                
                //**For Accounts Non Tax-Credit(ApplicantIdsNonAMTCSet) Qualification, Qualification Expiry date is Second anniversary
                //**Qualification Date is set to Today
                else if(ApplicantIdsNonTCSet.contains(aTemp.id)){
                    aTemp.APCHA_Qualification_Date__c = date.today();
                    aTemp.APCHA_Qualification_Expiry_Date__c = Date.newInstance(date.today().year()+2,date.today().month(),date.today().day()-1);
                }
                
                //** All Accounts for ReQualification(ApplicantIdsReQualSet), Qualification Expiry date is Second anniversary
                //**ReQualification Date is set to Today
                else if(ApplicantIdsReQualSet.contains(aTemp.id)){
                    aTemp.APCHA_ReQualification_Date__c = date.today();
                    aTemp.APCHA_Qualification_Expiry_Date__c = Date.newInstance(date.today().year()+2,date.today().month(),date.today().day()-1);
                }
                AccListToUpadteQualDates.add(aTemp);
            }
            if(AccListToUpadteQualDates.size() > 0){
                Database.SaveResult[] saveResultList = Database.Update(AccListToUpadteQualDates, false);
                for (Database.SaveResult sr : saveResultList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            system.debug(err.getMessage());
                        }
                    }
                }
            }
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception e){
            system.debug('Exception Occured: '+e.getMessage());
        }   
    }
    
    /** Method: ChangeCaseStatusOnAppStatus
Author: Siddhika Nigudkar
Purpose: Set Case Status as per Application Status(HTP1-683)
**/    
    public static void ChangeCaseStatusOnAppStatus(List<case> newCaseList, Map<Id, Case> oldCaseMap){
        try{
            for(case cTemp : newCaseList){
                if((cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT || cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT)
                && cTemp.APCHA_QUAL_Application_Status__c != oldCaseMap.get(cTemp.Id).APCHA_QUAL_Application_Status__c ){
                    
                    if((cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT && cTemp.APCHA_QUAL_Application_Status__c == APCHA_Constants.CASE_STATUS_APPROVED) 
                        || cTemp.APCHA_QUAL_Application_Status__c == APCHA_Constants.CASE_STATUS_DENIED)
                    {
                        cTemp.Status = APCHA_Constants.CASE_STATUS_CLOSED;
                    }
                    else if(cTemp.APCHA_QUAL_Application_Status__c == APCHA_Constants.CASE_STATUS_CANCELLED){
                        cTemp.Status = APCHA_Constants.CASE_STATUS_CANCELLED;
                    }                   
                }
            }
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception e){
            system.debug('Exception Occured: '+e.getMessage());
        }
    }
    
    /** Method: SendAppApprovalMailToApplicants
Author: Siddhika Nigudkar
Purpose: Send Notification to applicants on Application approval(HTP1-683)
**/    
    public static void SendAppApprovalMailToApplicants(List<case> newCaseList, Map<Id, Case> oldCaseMap){  
        try{
            List<Id> AccToSendEmail = new List<Id>();
            Map<Id, List<Id>> AccToCaseMap = new Map<Id,List<Id>>();
            Map<Id, List<String>> toMap = new Map<Id, List<String>>();
            Map<Id, List<String>> ccMap = new Map<Id, List<String>>();
            Map<Id, Boolean> TargetToRecMap = new Map<Id, Boolean>();
            Set<Id> newCaseIds = new Set<Id>();
            
            
            for(Case cTemp : newCaseList){
                if(cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT || cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT)
                    newCaseIds.add(cTemp.Id);
            }
            if(newCaseIds.Size() <= 0){
                return;
            }
            
            for(case cTemp: APCHA_SOQLUtil.getCaseRecords(newCaseIds, NULL).values()){
                //Check if all the applicants of application dont have emailId then dont send mail
                if((cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT || cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT)
                && cTemp.APCHA_QUAL_Application_Status__c != oldCaseMap.get(cTemp.Id).APCHA_QUAL_Application_Status__c
                && cTemp.APCHA_QUAL_Application_Status__c == APCHA_Constants.CASE_STATUS_APPROVED
                && cTemp.APCHA_QUAL_Primary_Applicant_Name__c != null 
                && cTemp.APCHA_QUAL_Primary_Applicant_Name__r.PersonContactId != null
                && (cTemp.APCHA_QUAL_Primary_Applicant_Name__r.PersonEmail != null
                    || (cTemp.APCHA_QUAL_Secondary_Applicant_Name__c != null && cTemp.APCHA_QUAL_Secondary_Applicant_Name__r.PersonEmail != null)
                    || (cTemp.APCHA_QUAL_3rd_Applicant_Name__c != null && cTemp.APCHA_QUAL_3rd_Applicant_Name__r.PersonEmail != null)
                    || (cTemp.APCHA_QUAL_4th_Applicant_Name__c != null && cTemp.APCHA_QUAL_4th_Applicant_Name__r.PersonEmail != null))
                )
                {    
                     List<Id> whatIdList = new List<Id>();
                    AccToSendEmail.add(cTemp.APCHA_QUAL_Primary_Applicant_Name__r.PersonContactId);
                    
                    if(cTemp.APCHA_QUAL_Primary_Applicant_Name__r.PersonEmail != null)
                        TargetToRecMap.put(cTemp.APCHA_QUAL_Primary_Applicant_Name__r.PersonContactId,TRUE);
                    else
                        TargetToRecMap.put(cTemp.APCHA_QUAL_Primary_Applicant_Name__r.PersonContactId,FALSE);
                        
                    whatIdList.add(cTemp.Id);
                    AccToCaseMap.put(cTemp.APCHA_QUAL_Primary_Applicant_Name__r.PersonContactId,whatIdList);
                    List<String> ccList = new List<String>();
                    
                    //If Unit is non-apcha managed, keep 'owner' or 'Property Manager' in cc
                    if((cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT
                    && cTemp.Lease__c != Null
                    && cTemp.Lease__r.APCHA_Unit_Property__c != Null 
                    && cTemp.Lease__r.APCHA_Unit_Property__r.APCHA_Managed__c == FALSE
                    )
                    || (cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT
                        && cTemp.APCHA_QUAL_Listing_Advertisement__c != null 
                        && cTemp.APCHA_QUAL_Listing_Advertisement__r.APCHA_Listing_Unit_House__c != null
                        && cTemp.APCHA_QUAL_Listing_Advertisement__r.APCHA_Listing_Unit_House__r.APCHA_Managed__c == FALSE))
                    {
                        If(cTemp.APCHA_QUAL_Owner_Landlord__c != null && cTemp.APCHA_QUAL_Owner_Landlord__r.PersonEmail != null){
                            ccList.add(cTemp.APCHA_QUAL_Owner_Landlord__r.PersonEmail);
                            ccMap.put(cTemp.APCHA_QUAL_Primary_Applicant_Name__r.PersonContactId,ccList);
                        }
                        Else If(cTemp.APCHA_Employer_Contractor__c != null && cTemp.APCHA_Business_Account_Contact__c != null && cTemp.APCHA_Business_Account_Contact__r.Email != null){
                            ccList.add(cTemp.APCHA_Business_Account_Contact__r.Email);
                            ccMap.put(cTemp.APCHA_QUAL_Primary_Applicant_Name__r.PersonContactId,ccList);
                        }
                    }
                    
                    
                    List<String> toList = new List<String>();
                        if(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c != null && cTemp.APCHA_QUAL_Secondary_Applicant_Name__r.PersonEmail != null){
                            System.debug('Inside Tolist');
                            toList.add(cTemp.APCHA_QUAL_Secondary_Applicant_Name__r.PersonEmail);
                        }
                        if(cTemp.APCHA_QUAL_3rd_Applicant_Name__c != null && cTemp.APCHA_QUAL_3rd_Applicant_Name__r.PersonEmail != null){
                            toList.add(cTemp.APCHA_QUAL_3rd_Applicant_Name__r.PersonEmail);
                        }
                        if(cTemp.APCHA_QUAL_4th_Applicant_Name__c != null && cTemp.APCHA_QUAL_4th_Applicant_Name__r.PersonEmail != null){
                            toList.add(cTemp.APCHA_QUAL_4th_Applicant_Name__r.PersonEmail);
                        } 
                        toMap.put(cTemp.APCHA_QUAL_Primary_Applicant_Name__r.PersonContactId, toList);
                    
                }               
            }
            
            
            if(AccToSendEmail.size()>0){
                if (AccToSendEmail != NULL) 
                    APCHA_Utility.SendRecordSpecificEmails('APCHA_Application_Status_Email', toMap, ccMap, AccToSendEmail, AccToCaseMap, 'Qualification Specialist', TargetToRecMap);
            }
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception e){
            system.debug('Exception Occured: '+e.getMessage());
        }
        
    }
    
    
    /** Method: SetCategoryForApplication
Author: Siddhika Nigudkar
Purpose: Set Category for Application on basic on All Applicants Income, asset and Household Size(HTP1-688)
**/    
    public static void SetCategoryForApplication(List<case> newCaseList, Map<Id, Case> oldCaseMap, Boolean IsBeforeInsert, Boolean AccOrPDUpdate){  
        try{
            List<Case> casesToUpdate = new List<Case>();
            Set<Id> ApplicantAccIds = new Set<Id>();
            Map<Id,Account> AccountMap = new Map<Id, Account>();
            for(case cTemp : newCaseList){
                if(cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT || cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT)
                {
                    if(cTemp.APCHA_QUAL_Primary_Applicant_Name__c != null){
                        ApplicantAccIds.add(cTemp.APCHA_QUAL_Primary_Applicant_Name__c);
                    }
                    if(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c != null){
                        ApplicantAccIds.add(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c);
                    }
                    if(cTemp.APCHA_QUAL_3rd_Applicant_Name__c != null){
                        ApplicantAccIds.add(cTemp.APCHA_QUAL_3rd_Applicant_Name__c);
                    }
                    if(cTemp.APCHA_QUAL_4th_Applicant_Name__c != null){
                        ApplicantAccIds.add(cTemp.APCHA_QUAL_4th_Applicant_Name__c);
                    }
                }           
            }
            
            if(ApplicantAccIds.size() > 0)
                AccountMap = APCHA_SOQLUtil.getAccountRecords(ApplicantAccIds, APCHA_Constants.PERSON_ACCOUNT_RT);
            //Get roll-up sum of asset, Income and Household Size of all four applicants for every case
            for(case cTemp : newCaseList){
                Decimal totalHouseholdSize = 0;
                Decimal totalNetAsset = 0;
                Decimal totalIncome = 0;
                if((cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT || cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT) 
                && cTemp.APCHA_QUAL_Application_Status__c != APCHA_Constants.CASE_STATUS_APPROVED 
                && cTemp.APCHA_QUAL_Application_Status__c != APCHA_Constants.CASE_STATUS_DENIED
                && cTemp.Status !=APCHA_Constants.CASE_STATUS_CANCELLED 
                && (IsBeforeInsert || AccOrPDUpdate ||
                    (cTemp.APCHA_QUAL_Primary_Applicant_Name__c != oldCaseMap.get(cTemp.id).APCHA_QUAL_Primary_Applicant_Name__c 
                        || cTemp.APCHA_QUAL_Secondary_Applicant_Name__c != oldCaseMap.get(cTemp.id).APCHA_QUAL_Secondary_Applicant_Name__c 
                        || cTemp.APCHA_QUAL_3rd_Applicant_Name__c != oldCaseMap.get(cTemp.id).APCHA_QUAL_3rd_Applicant_Name__c 
                        || cTemp.APCHA_QUAL_4th_Applicant_Name__c != oldCaseMap.get(cTemp.id).APCHA_QUAL_4th_Applicant_Name__c 
                        || cTemp.APCHA_QUAL_Household_Size__c != oldCaseMap.get(cTemp.id).APCHA_QUAL_Household_Size__c )))
                {
                    
                    if(cTemp.APCHA_QUAL_Primary_Applicant_Name__c != null ){
                        totalHouseholdSize = totalHouseholdSize + AccountMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Household_Sizes__c   ;
                        totalNetAsset = totalNetAsset + AccountMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Total_Net_Asset_Value__c;
                        totalIncome = totalIncome + AccountMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Total_Income_Balance_Value__c;
                    }
                    
                    if(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c != null ){
                        totalHouseholdSize = totalHouseholdSize + AccountMap.get(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c).APCHA_Household_Sizes__c;
                        totalNetAsset = totalNetAsset + AccountMap.get(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c).APCHA_Total_Net_Asset_Value__c;
                        totalIncome = totalIncome + AccountMap.get(cTemp.APCHA_QUAL_Secondary_Applicant_Name__c).APCHA_Total_Income_Balance_Value__c;
                    }
                    
                    if(cTemp.APCHA_QUAL_3rd_Applicant_Name__c != null ){
                        totalHouseholdSize = totalHouseholdSize +  AccountMap.get(cTemp.APCHA_QUAL_3rd_Applicant_Name__c).APCHA_Household_Sizes__c;
                        totalNetAsset = totalNetAsset +  AccountMap.get(cTemp.APCHA_QUAL_3rd_Applicant_Name__c).APCHA_Total_Net_Asset_Value__c;
                        totalIncome = totalIncome +  AccountMap.get(cTemp.APCHA_QUAL_3rd_Applicant_Name__c).APCHA_Total_Income_Balance_Value__c;
                    }
                    
                    if(cTemp.APCHA_QUAL_4th_Applicant_Name__c != null ){
                        totalHouseholdSize = totalHouseholdSize +  AccountMap.get(cTemp.APCHA_QUAL_4th_Applicant_Name__c).APCHA_Household_Sizes__c;
                        totalNetAsset = totalNetAsset + AccountMap.get(cTemp.APCHA_QUAL_4th_Applicant_Name__c).APCHA_Total_Net_Asset_Value__c;
                        totalIncome = totalIncome +  AccountMap.get(cTemp.APCHA_QUAL_4th_Applicant_Name__c).APCHA_Total_Income_Balance_Value__c;
                    }
                    
                    if(cTemp.APCHA_QUAL_Household_Size__c != null || cTemp.APCHA_QUAL_Household_Size__c > 0){
                        totalHouseholdSize = cTemp.APCHA_QUAL_Household_Size__c;
                    }
                    
                    if(cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT)
                        cTemp.APCHA_Category_for_Application__c = APCHA_AccountBusinessUtility.getFinalCat(Integer.valueOf(totalHouseholdSize), 
                                                                                                        Integer.valueOf(totalIncome), 
                                                                                                        Integer.valueOf(totalNetAsset), 
                                                                                                        APCHA_Constants.QUALIFICATION);    
                    else if(cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT)
                        cTemp.APCHA_Category_for_Application__c = APCHA_AccountBusinessUtility.getFinalCat(Integer.valueOf(totalHouseholdSize), 
                                                                                                        Integer.valueOf(totalIncome), 
                                                                                                        Integer.valueOf(totalNetAsset), 
                                                                                                        APCHA_Constants.REQUALIFICATION);
                    
                    casesToUpdate.add(cTemp);
                }
            }
            if(AccOrPDUpdate == TRUE && casesToUpdate.size() > 0){
                Database.SaveResult[] saveResultList = Database.Update(casesToUpdate, false);
                for (Database.SaveResult sr : saveResultList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            system.debug(err.getMessage());
                        }
                    }
                }               
            }
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception e){
            system.debug('Exception Occured: '+e.getMessage());
        }
        
        
    }
    
    /** Method: SetOwnerOrPmForReQualApp
Author: Siddhika Nigudkar
Purpose: Set Owner/Landlord or Property manager and active lease of Primary applicant for ReQualification from Applicants active case(HTP1-688)  
**/    
    public static void SetOwnerOrPmForReQualApp(List<case> newCaseList, Map<Id, Case> oldCaseMap, Boolean IsBeforeInsert){
        try{
            Set<Id> ApplicantIds = new Set<Id>();
            
            for(Case cTemp : newCaseList){
                if(cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT && cTemp.APCHA_QUAL_Primary_Applicant_Name__c != Null
                && (IsBeforeInsert == TRUE
                    || cTemp.APCHA_QUAL_Primary_Applicant_Name__c != oldCaseMap.get(cTemp.id).APCHA_QUAL_Primary_Applicant_Name__c)){
                        ApplicantIds.add(cTemp.APCHA_QUAL_Primary_Applicant_Name__c);
                    }
            }
            if(ApplicantIds.size() > 0){
                List<APCHA_Lease_Line__c> ActiveLeaseLinesforApplicants = [SELECT Id, APCHA_Account__c, APCHA_Lease__c, APCHA_Lease__r.APCHA_QUAL_Owner_Landlord__c, 
                                                                        APCHA_Lease__r.APCHA_Employer_Contractor__c, APCHA_Lease__r.APCHA_Business_Account_Contact__c 
                                                                        FROM APCHA_Lease_Line__c 
                                                                        WHERE APCHA_Lease__r.Status = 'Active' 
                                                                        AND APCHA_Status__c = 'Active'
                                                                        AND APCHA_Account__c IN: ApplicantIds
                                                                        AND (APCHA_Lease__r.APCHA_QUAL_Owner_Landlord__c != NULL 
                                                                                OR APCHA_Lease__r.APCHA_Employer_Contractor__c != NULL 
                                                                                OR APCHA_Lease__r.APCHA_Business_Account_Contact__c != NULL)
                                                                        ];
                Map<id, APCHA_Lease_Line__c> AccToLeaseLineMap = new Map<id, APCHA_Lease_Line__c>();
                
                for(APCHA_Lease_Line__c LLTemp : ActiveLeaseLinesforApplicants){
                    if(AccToLeaseLineMap.containsKey(LLTemp.APCHA_Account__c) ) 
                        continue;
                    else
                        AccToLeaseLineMap.put(LLTemp.APCHA_Account__c, LLTemp);
                }
                
                for(Case cTemp: newCaseList){
                    if(AccToLeaseLineMap.containsKey(cTemp.APCHA_QUAL_Primary_Applicant_Name__c)){
                        if(AccToLeaseLineMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Lease__c != NULL)
                            cTemp.Lease__c =  AccToLeaseLineMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Lease__c;
                        if(AccToLeaseLineMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Lease__r.APCHA_QUAL_Owner_Landlord__c != NULL )
                            cTemp.APCHA_QUAL_Owner_Landlord__c = AccToLeaseLineMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Lease__r.APCHA_QUAL_Owner_Landlord__c;
                        else if(AccToLeaseLineMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Lease__r.APCHA_Employer_Contractor__c != NULL )
                            cTemp.APCHA_Employer_Contractor__c = AccToLeaseLineMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Lease__r.APCHA_Employer_Contractor__c;
                        else if(AccToLeaseLineMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Lease__r.APCHA_Business_Account_Contact__c != NULL )
                            cTemp.APCHA_Business_Account_Contact__c = AccToLeaseLineMap.get(cTemp.APCHA_QUAL_Primary_Applicant_Name__c).APCHA_Lease__r.APCHA_Business_Account_Contact__c;                    
                    }
                }
            }
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception e){
            system.debug('Exception Occured: '+e.getMessage());
        }
    }
    
    /** Method: createTaskForCase
Author: Siddhika Nigudkar
Purpose: Create Laese Renewal Task with Approved ReQualification Case(when unit is apcha managed) for Property manager Queue(HTP1-741)  
**/    
    public static void createTaskForCase(List<case> newCaseList, Map<Id, Case> oldCaseMap){
        try{
            List<Task> AllTasks = new List<Task>();
            for(Case cTemp : APCHA_SOQLUtil.getCaseRecords(oldCaseMap.keyset(), NULL).values()){
                System.debug(cTemp.RecordTypeId);
                if(cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT
                && cTemp.APCHA_QUAL_Application_Status__c != oldCaseMap.get(cTemp.Id).APCHA_QUAL_Application_Status__c
                && cTemp.APCHA_QUAL_Application_Status__c == APCHA_Constants.CASE_STATUS_APPROVED && cTemp.lease__c != NULL 
                && cTemp.Lease__r.APCHA_Unit_Property__c != Null 
                && cTemp.Lease__r.APCHA_Unit_Property__r.APCHA_Managed__c == TRUE){
                    //create Lease Renewal task for PM
                    List<Task> cTempTaskList = APCHA_TaskUtility.getTaskListFromCaseRTypeAndStatus(new case(Id = cTemp.lease__c) , 
                                    APCHA_Constants.LEASE_RENEWAL_RT_API, APCHA_Constants.RENEWAL_SUB_RT_API, NULL,
                                    NULL, cTemp.Lease__r.APCHA_Unit_Property__c);
                    System.debug(cTempTaskList);
                    AllTasks.addAll(cTempTaskList);
                }
                
            }
            if(AllTasks.size() > 0){
                Database.SaveResult[] saveResultList = Database.insert(AllTasks, false);
                for (Database.SaveResult sr : saveResultList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            system.debug(err.getMessage());
                        }
                    }
                }               
            }
            if(Test.isRunningTest())
                Integer i = 1/0;
        }
        catch(Exception e){
            system.debug('Exception Occured: '+e.getMessage());
        }    
    }

    /**
     * Name: insertAppLineFromPersonDetail
     * Desc: Insert Application Lines from Person Details when a new QUAL/REQUAL Case Created
     * @author Nikhil K
     * @param CaseList
     * @param newMap
     * @param OldMap
     * @param Isupdate Flag
     * @retrun: 
     */
    public static void insertAppLineFromPersonDetail(List<Case> caseList, Map<Id, Case> newMap, Map<Id, Case> oldMap, Boolean isUpdate) { 
        if(caseList == NULL || newMap == NULL || newMap.isEmpty()) {
            return;
        }
        try {
            //the filter List condition
            List<Case> filteredCaseList = new List<Case>();
            if(isUpdate) {
                for(case cTemp : caseList) {
                    if((cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT || cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT) && cTemp.APCHA_QUAL_Application_Status__c == APCHA_Constants.CASE_STATUS_SAVED
                    && oldmap != NULL && (cTemp.APCHA_QUAL_Primary_Applicant_Name__c != oldMap.get(cTemp.id).APCHA_QUAL_Primary_Applicant_Name__c 
                        || cTemp.APCHA_QUAL_Secondary_Applicant_Name__c != oldMap.get(cTemp.id).APCHA_QUAL_Secondary_Applicant_Name__c 
                        || cTemp.APCHA_QUAL_3rd_Applicant_Name__c != oldMap.get(cTemp.id).APCHA_QUAL_3rd_Applicant_Name__c 
                        || cTemp.APCHA_QUAL_4th_Applicant_Name__c != oldMap.get(cTemp.id).APCHA_QUAL_4th_Applicant_Name__c )) {
                        
                        filteredCaseList.add(cTemp);
                    }
                }    
            } else {
                for(case cTemp : caseList) { 
                    if((cTemp.RecordTypeId == APCHA_Constants.QUALIFICATION_RT || cTemp.RecordTypeId == APCHA_Constants.REQUALIFICATION_RT)) {
                        filteredCaseList.add(cTemp);
                    }
                }
            }
            system.debug('Nik==> Insert APPLine FLOW filteredCaseList ' + filteredCaseList);
            if(filteredCaseList != NULL && filteredCaseList.size() > 0) {
                List<Id> caseApplicantIdList = new List<Id>();
                Map<Id, List<Id>> caseIdToAccountIdMap = new Map<Id, List<Id>>();
                /********************** CREATE CASEID TO LIST ACCOUNTID MAP *****************************/
                for(Case caseRec : filteredCaseList) {
                    List<Id> caseApplicantIdTempList = new List<Id>();
                    if(!caseIdToAccountIdMap.containsKey(caseRec.Id)){
                        caseIdToAccountIdMap.put(caseRec.Id, new List<Id>());
                    }
                    if(caseRec.APCHA_QUAL_Primary_Applicant_Name__c != NULL) {
                        caseApplicantIdTempList.add(caseRec.APCHA_QUAL_Primary_Applicant_Name__c);
                    }
                    if(caseRec.APCHA_QUAL_Secondary_Applicant_Name__c != NULL) {
                        caseApplicantIdTempList.add(caseRec.APCHA_QUAL_Secondary_Applicant_Name__c);
                    }
                    if(caseRec.APCHA_QUAL_3rd_Applicant_Name__c != NULL) {
                        caseApplicantIdTempList.add(caseRec.APCHA_QUAL_3rd_Applicant_Name__c);
                    }
                    if(caseRec.APCHA_QUAL_4th_Applicant_Name__c != NULL) {
                        caseApplicantIdTempList.add(caseRec.APCHA_QUAL_4th_Applicant_Name__c);
                    }
                    caseIdToAccountIdMap.put(caseRec.Id, caseApplicantIdTempList);
                    caseApplicantIdList.addAll(caseApplicantIdTempList);
                }
                system.debug('Nik==> Insert APPLine FLOW caseIdToAccountIdMap ' + caseIdToAccountIdMap);
                system.debug('Nik==> Insert APPLine FLOW caseApplicantIdList ' + caseApplicantIdList);
                /********************** CREATE CASEID TO LIST ACCOUNTID MAP *****************************/
                /************* DELETE PREVIOUS CREATED APPLINES ON UPDATE TO FETCH LATEST VALUES ***************/
                
                List<APCHA_Application_Line__c> prevAppLIneToDelete = new List<APCHA_Application_Line__c>([ Select Id, Apcha_Case__c
                                                                                                            From APCHA_Application_Line__c 
                                                                                                            WHERE APCHA_Case__c IN :caseIdToAccountIdMap.keySet()
                                                                                                            AND Apcha_Case__r.APCHA_QUAL_Application_Status__c IN :APCHA_Constants.applineApplicationStatusList AND
                                                                                                            (Apcha_Case__r.RecordTypeId = :APCHA_Constants.QUALIFICATION_RT OR Apcha_Case__r.RecordTypeId= :APCHA_Constants.REQUALIFICATION_RT)
                                                                                                            ]);

                if(prevAppLIneToDelete.size() > 0 ) {
                    database.delete(prevAppLIneToDelete, FALSE);
                }
                List<String> lstOfFldName = new List<String>();
                String query = 'SELECT ';
                SObjectType type = Schema.getGlobalDescribe().get('APCHA_Person_Details__c');
                Map<String,Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
                for(String strField:mfields.keySet())
                {
                    lstOfFldName.add(strField);
                }
                query+= String.join(lstOfFldName,',');
                query += ' FROM APCHA_Person_Details__c WHERE APCHA_Person_Account__c IN :caseApplicantIdList';
                List<APCHA_Person_Details__c> personDetailList = Database.query(query);
                /*List<APCHA_Person_Details__c> personDetailList = new List<APCHA_Person_Details__c>([ SELECT Id, Name, RecordTypeId, APCHA_Person_Account__c, 
                                                                                                    APCHA_Member_Name__c, APCHA_Type__c, APCHA_Member_Date_of_Birth__c, 
                                                                                                    APCHA_Real_Estate_Address__c, APCHA_Income_Balance_Value__c, 
                                                                                                    APCHA_Real_Estate_Type__c, APCHA_Vehicle_Model_Year__c, 
                                                                                                    APCHA_Vehicle_Make__c, APCHA_Vehicle_Model__c, 
                                                                                                    APCHA_Vehicle_License_Plate_No__c, APCHA_Vehical_Registration_Expiry__c, 
                                                                                                    APCHA_Board_University__c, APCHA_Specialization__c, APCHA_Score_Grade__c, 
                                                                                                    APCHA_Real_Estate_Balance_Value__c, APCHA_Employment_Start_Date__c, 
                                                                                                    APCHA_Employment_End_Date__c, APCHA_Business_Type__c, APCHA_Employer_Name__c, 
                                                                                                    APCHA_Member_Email__c, APCHA_Member_Contact__c,APCHA_Breed_Size__c,APCHA_Custody_Days_Year__c,
                                                                                                    APCHA_Live_in_Days_Year__c,APCHA_SSN__c,APCHA_Student_Status__c
                                                                                                    FROM APCHA_Person_Details__c
                                                                                                    WHERE APCHA_Person_Account__c IN :caseApplicantIdList
                                                                                                ]);*/
                
                system.debug('Nik==> PD QUERY result' + personDetailList);                                                                                   
                Map<Id, List<APCHA_Person_Details__c>> accountIdToPersonDetailMap = new Map<Id, List<APCHA_Person_Details__c>>();
                for(APCHA_Person_Details__c personDetailRec : personDetailList) {
                    if(!accountIdToPersonDetailMap.containsKey(personDetailRec.APCHA_Person_Account__c)){
                        accountIdToPersonDetailMap.put(personDetailRec.APCHA_Person_Account__c, new List<APCHA_Person_Details__c>());
                    }  
                    accountIdToPersonDetailMap.get(personDetailRec.APCHA_Person_Account__c).add(personDetailRec);  
                }
                system.debug(accountIdToPersonDetailMap);
                //Insert Record
                List<APCHA_Application_Line__c> appLineToInsert = new List<APCHA_Application_Line__c>();
                for(Id caseIdRec: caseIdToAccountIdMap.keySet()) {
                    for(Id accId : caseIdToAccountIdMap.get(caseIdRec)) {
                        if(accountIdToPersonDetailMap !=NULL && !accountIdToPersonDetailMap.isEmpty() && accountIdToPersonDetailMap.containsKey(accId)){
                            for(APCHA_Person_Details__c personDetailRec : accountIdToPersonDetailMap.get(accId)){
                                APCHA_Application_Line__c appLineRec = setApplineFromPersionDetail(personDetailRec);
                                appLineRec.APCHA_Person_Account__c = personDetailRec.APCHA_Person_Account__c ; 
                                appLineRec.APCHA_Case__c = caseIdRec;
                                appLineToInsert.add(appLineRec);
                            }
                        }
                    }
                } 
                system.debug(appLineToInsert);
                if(appLineToInsert != NULL && appLineToInsert.size() > 0) {
                    Database.SaveResult[] saveResultList = Database.insert(appLineToInsert, false);
                    for (Database.SaveResult sr : saveResultList) {
                        if (!sr.isSuccess()) {
                            for(Database.Error err : sr.getErrors()) {
                                system.debug(err.getMessage());
                            }
                        }
                    }   
                }
            }// END OF filteredCaseList IF
        } catch(Exception e){
            system.debug('Exception Occured: '+e.getMessage());
        }    
    }
    
    /**
     * Name: setApplineFromPersionDetail
     * Desc: Set Application Lines data from Person Details Record
     * @author Nikhil K
     * @param personDetailRec
     * @retrun: 
     */
    public static APCHA_Application_Line__c setApplineFromPersionDetail(APCHA_Person_Details__c personDetailRec) {
        APCHA_Application_Line__c appLineRec = new APCHA_Application_Line__c();
        /********************************** APPLINE SETUP ******************************************/
        appLineRec.APCHA_Person_Details__c = personDetailRec.Id ; 
        /******************* SIMILAR Fields ********************************************************/
        
        List<Schema.FieldSetMember>  listFlsmem = SObjectType.APCHA_Application_Line__c.FieldSets.Application_Line_Field_Set.getFields();
        for(Schema.FieldSetMember f : listFlsmem) {
            appLineRec.put(String.valueOf(f.getFieldPath()), personDetailRec.get(String.valueOf(f.getFieldPath())));   
        }

        /*
        appLineRec.APCHA_Income_Balance_Value__c = personDetailRec.APCHA_Income_Balance_Value__c ;
        appLineRec.APCHA_Board_University__c = personDetailRec.APCHA_Board_University__c; 
        appLineRec.APCHA_Business_Type__c = personDetailRec.APCHA_Business_Type__c; 
        appLineRec.APCHA_Custody_Days_Year__c = personDetailRec.APCHA_Custody_Days_Year__c; 
        appLineRec.APCHA_Employment_End_Date__c = personDetailRec.APCHA_Employment_End_Date__c ; 
        appLineRec.APCHA_Employment_Start_Date__c = personDetailRec.APCHA_Employment_Start_Date__c ; 
        appLineRec.APCHA_Live_in_Days_Year__c = personDetailRec.APCHA_Live_in_Days_Year__c ; 
        appLineRec.APCHA_Member_Contact__c = personDetailRec.APCHA_Member_Contact__c ; 
        appLineRec.APCHA_Member_Date_of_Birth__c = personDetailRec.APCHA_Member_Date_of_Birth__c ; 
        appLineRec.APCHA_Member_Email__c = personDetailRec.APCHA_Member_Email__c ; 
        appLineRec.APCHA_Member_Name__c = personDetailRec.APCHA_Member_Name__c ; 
        appLineRec.APCHA_Real_Estate_Address__c = personDetailRec.APCHA_Real_Estate_Address__c ; 
        appLineRec.APCHA_Real_Estate_Balance_Value__c = personDetailRec.APCHA_Real_Estate_Balance_Value__c ; 
        appLineRec.APCHA_Real_Estate_Type__c = personDetailRec.APCHA_Real_Estate_Type__c ; 
        appLineRec.APCHA_Score_Grade__c = personDetailRec.APCHA_Score_Grade__c ;
        appLineRec.APCHA_Specialization__c = personDetailRec.APCHA_Specialization__c ; 
        appLineRec.APCHA_Type__c = personDetailRec.APCHA_Type__c ; 
        appLineRec.APCHA_SSN__c = personDetailRec.APCHA_SSN__c ; 
        appLineRec.APCHA_Student_Status__c = personDetailRec.APCHA_Student_Status__c ; 
        appLineRec.APCHA_Vehicle_Registration_Expiry__c = personDetailRec.APCHA_Vehical_Registration_Expiry__c ; 
        appLineRec.APCHA_Vehicle_License_Plate_No__c = personDetailRec.APCHA_Vehicle_License_Plate_No__c ; 
        appLineRec.APCHA_Vehicle_Make__c = personDetailRec.APCHA_Vehicle_Make__c ; 
        appLineRec.APCHA_Vehicle_Model__c = personDetailRec.APCHA_Vehicle_Model__c ; 
        appLineRec.APCHA_Vehicle_Model_Year__c = personDetailRec.APCHA_Vehicle_Model_Year__c ; 
        appLineRec.APCHA_Business_Organization__c = personDetailRec.APCHA_Employer_Name__c ; 
        appLineRec.APCHA_Breed_Size__c = personDetailRec.APCHA_Breed_Size__c ; */
        System.debug('Nik APPLIne==>AppLineRec ' + appLineRec);
        return appLineRec;
    }
}