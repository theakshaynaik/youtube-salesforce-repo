/**
* @author Akshay Naik
* @date 03/05/2025
* @description Execute Twilio Studio Flow for initiating IVR calls
* @warning NOT PRODUCTION READY
*/
public with sharing class TwilioFlowExecutor {
    public static void invokeIvr(String toPhoneNumber, String fromPhoneNumber) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Twilio_IVR/v2/Flows/FWed38f513cdb3c6f5479396fdecc1abcd/Executions');
            request.setMethod('POST');
            String recId = '00Q5j000005KmAeEAK';
            String sfUserName = UserInfo.getUserName();
            String params = '{"recId":"' + recId + '","sfUserName":"' + sfUserName + '","reminderMsg":"Hi, this is Astro Atlas checking in on your recent proposal. Press 1 if you are ready to move forward, 2 if you are no longer interested."}';
            String requestBody = 'To=' + EncodingUtil.urlEncode(toPhoneNumber, 'UTF-8') + '&From=' + EncodingUtil.urlEncode(fromPhoneNumber, 'UTF-8') + '&Parameters=' + EncodingUtil.urlEncode(params, 'UTF-8');
            request.setBody(requestBody);
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 201) {
                System.debug('Success: ' + response.getBody());
            } else {
                System.debug('Failed: ' + response.getBody());
            }
        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}