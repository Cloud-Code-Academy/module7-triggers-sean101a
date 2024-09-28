trigger accountTrigger on Account (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        for (Account acc : Trigger.new) {
            // 1. Set Type to 'Prospect' if blank or null
            if (acc.Type == null || String.isBlank(acc.Type)) {
                acc.Type = 'Prospect';
            }

            // 2. Copy Shipping Address to Billing Address if shipping fields are not empty
            if (!String.isBlank(acc.ShippingStreet) ||
                !String.isBlank(acc.ShippingCity) ||
                !String.isBlank(acc.ShippingState) ||
                !String.isBlank(acc.ShippingPostalCode) ||
                !String.isBlank(acc.ShippingCountry)) {
                
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingCity = acc.ShippingCity;
                acc.BillingState = acc.ShippingState;
                acc.BillingPostalCode = acc.ShippingPostalCode;
                acc.BillingCountry = acc.ShippingCountry;
            }

            // 3. Set Rating to 'Hot' if Phone, Website, and Fax are all provided
            if (String.isNotBlank(acc.Phone) && String.isNotBlank(acc.Website) && String.isNotBlank(acc.Fax)) {
                acc.Rating = 'Hot';
            }
        }
    }

    // 4. After Insert: Create Default Contact
    if (Trigger.isAfter && Trigger.isInsert) {
        List<Contact> contactsToInsert = new List<Contact>();
        for (Account acc : Trigger.new) {
            Contact newContact = new Contact(
                LastName = 'DefaultContact',
                Email = 'default@email.com',
                AccountId = acc.Id
            );
            contactsToInsert.add(newContact);
        }
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }
}
