trigger opportunityTrigger on Opportunity (before update, before delete) {
    // 1. Opportunity Update - Validate Amount > 5000
    if (Trigger.isUpdate) {
        for (Opportunity opp : Trigger.new) {
            if (opp.Amount < 5000) {
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }
    
    // 2. Prevent Deletion of Closed Won Opportunities for Banking Accounts
    if (Trigger.isDelete) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.old) {
            if (opp.StageName == 'Closed Won') {
                accountIds.add(opp.AccountId);
            }
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Industry FROM Account WHERE Id IN :accountIds]
        );

        for (Opportunity opp : Trigger.old) {
            if (opp.StageName == 'Closed Won' && accountMap.containsKey(opp.AccountId) &&
                accountMap.get(opp.AccountId).Industry == 'Banking') {
                opp.addError('Cannot delete closed opportunity for a banking account that is won.');
            }
        }
    }
    
    // 3. Set Primary Contact to CEO on Opportunity Update
    if (Trigger.isUpdate) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        Map<Id, Contact> accountToCEOMap = new Map<Id, Contact>();
        for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO']) {
            accountToCEOMap.put(con.AccountId, con);
        }

        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null && accountToCEOMap.containsKey(opp.AccountId)) {
                opp.Primary_Contact__c = accountToCEOMap.get(opp.AccountId).Id;
            }
        }
    }
}
