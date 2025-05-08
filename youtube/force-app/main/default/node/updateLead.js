/**
* @author Akshay Naik
* @date 08/05/2025
* @description Consume Salesforce service from Twilio Studio Flow to update the lead status
* @warning NOT PRODUCTION READY
*/

const got = require('got');
const jwt = require('jsonwebtoken');
const FormData = require('form-data');

const clientId = 'vMkjMb3MVG9pRzO._16hcRst0Xsr1k.JF.3Cfxwxxxxxxxx5vgJbfql.WtFz3ao......';
const privateKey = `-----BEGIN RSA PRIVATE KEY-----
PLOa5dNuZVCcB1HeKJkQVqZcW4L8gS7vXzZCYplAqd+criKWQTnETe0GMKKy0TJh
MIIJQQIBADANBgkqhkiG9w0BAQEFAASCCSswggknAgEAAoICAQCaX6Y7adHbJUdE
VkANyiVcqnzaKaFbgcN0tRUkfUrGJQg1h4dDBE+WmRNKjzS17E6DzeCX5IEfswBu
jCQm27p9BjNGCQynpcmCFdswJXbQTIoDuX/KXz5kAzVUHBFiQT1BpbKf1jhxTDfQ
2j0k1m4v5X+3x6Zc7g9qz5J8QYwW4r7a0G9d1h2KXy3b6f8e5n.............
-----END RSA PRIVATE KEY-----`;
const SALESFORCE_API_VERSION = 'v59.0';

function getTokenInformation(sfUserName) {
  const options = {
    issuer: clientId,
    audience: 'https://login.salesforce.com',
    expiresIn: 180,
    algorithm: 'RS256'
  };
  const token = jwt.sign({ prn: sfUserName }, privateKey, options);
  const form = new FormData();
  form.append('grant_type', 'urn:ietf:params:oauth:grant-type:jwt-bearer');
  form.append('assertion', token);
  return got.post('https://login.salesforce.com/services/oauth2/token', {
      body: form
    })
    .then(response => JSON.parse(response.body));
}

async function updateLeadStatus(context, event, callback) {
  const LEAD_ID = event.recId;
  const sfUserName = event.sfUserName;
  const token = await getTokenInformation(sfUserName);
  const salesforceApiUrl = `${token.instance_url}/services/data/${SALESFORCE_API_VERSION}/sobjects/Lead/${LEAD_ID}`;
  const requestBody = JSON.stringify({ "Status": "Working - Contacted" });
  const response = await got.patch(salesforceApiUrl, {
    headers: {
      Authorization: `Bearer ${token.access_token}`,
      'Content-Type': 'application/json'
    },
    body: requestBody
  });
  callback(null, { success : true, message : response } );
}

exports.handler = updateLeadStatus;
