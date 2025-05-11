/**
* @author Akshay Naik
* @description Marketing Cloud Framework for executing API Event Journeys
* @warning NOT PRODUCTION READY
*/
public with sharing class MCInteraction implements Queueable, Database.AllowsCallouts {

    List<SObject> recordList;
    String processName;

    public MCInteraction(List<SObject> recordList, String processName) {
        this.recordList = recordList;
        this.processName = processName;
    }
    
    public void execute(QueueableContext context) {
        String mcInteractionJson = [SELECT MasterLabel, JsonConfig__c FROM MCInteraction__mdt WHERE MasterLabel = :processName].JsonConfig__c;
        if(String.isBlank(mcInteractionJson)) {
            return;
        }
        MCInteractionWrapper mcInteractObj = (MCInteractionWrapper) JSON.deserialize(mcInteractionJson, MCInteractionWrapper.class);
        String requestBody = getJourneyRequestBody(mcInteractObj, recordList);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Marketing_Cloud_Named_Credential/interaction/v1/async/events');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        Http http = new Http();
        try {
            HttpResponse response = http.send(request);
            System.debug('Journey Callout - Request: ' + requestBody);
            System.debug('Response Status: ' + response.getStatusCode());
            System.debug('Response Body: ' + response.getBody());
        } catch (Exception e) {
            System.debug('Journey Callout Exception: ' + e.getMessage());
        }
    }

    private static String getJourneyRequestBody(MCInteractionWrapper mcInteractObj, List<SObject> recordList) {
        List<Map<String, Object>> members = new List<Map<String, Object>>();
        for(SObject record : recordList) {
            Map<String, Object> dataMap = new Map<String, Object>();
            for(String sfField : mcInteractObj.fieldAttributeMapping.keySet()) {
                String targetAttribute = mcInteractObj.fieldAttributeMapping.get(sfField);
                String value = (String) record.get(sfField);
                dataMap.put(targetAttribute, value);
            }
            members.add(new Map<String, Object>{
                'contactKey' => dataMap.get(mcInteractObj.subscriberKeyAttribute),
                'data' => dataMap
            });
        }
        return JSON.serialize(new Map<String, Object>{
            'eventDefinitionKey' => mcInteractObj.definitionKey,
            'members' => members
        });
    }
   
    private class MCInteractionWrapper {
        public String definitionKey;
        public String subscriberKeyAttribute;
        public Map<String, String> fieldAttributeMapping;
    }
}

/*
Sample configuration for MCInteraction__mdt:
{
  "definitionKey": "6288B52F-C76C-49BF-BE49-01C181EFB52D",
  "subscriberKeyAttribute": "email_address",
  "fieldAttributeMapping": {
    "FirstName": "first_name",
    "LastName": "last_name",
    "Email": "email_address",
    "Id": "sf_id"
  }
}
*/
