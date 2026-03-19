import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_POINT_TYPE_CONSENT_OBJECT from '@salesforce/schema/ContactPointTypeConsent';
import NAME_FIELD from '@salesforce/schema/ContactPointTypeConsent.Name';
import PRIVACY_CONSENT_STATUS_FIELD from '@salesforce/schema/ContactPointTypeConsent.PrivacyConsentStatus';
import DATA_USE_PURPOSE_FIELD from '@salesforce/schema/ContactPointTypeConsent.DataUsePurposeId';
import BUSINESS_BRAND_FIELD from '@salesforce/schema/ContactPointTypeConsent.BusinessBrandId';

export default class ContactPointTypeConsentForm extends LightningElement {
    @api consent;

    objectInfo;

    @wire(getObjectInfo, { objectApiName: CONTACT_POINT_TYPE_CONSENT_OBJECT })
    wiredObjectInfo({ data }) {
        if (data) {
            this.objectInfo = data;
        }
    }

    get nameLabel() {
        return this.getFieldLabel(NAME_FIELD.fieldApiName, 'Name');
    }

    get activeLabel() {
        return this.getFieldLabel(PRIVACY_CONSENT_STATUS_FIELD.fieldApiName, 'Privacy Consent Status');
    }

    get dataUsePurposeLabel() {
        return this.getFieldLabel(DATA_USE_PURPOSE_FIELD.fieldApiName, 'Data Use Purpose');
    }

    get businessBrandLabel() {
        return this.getFieldLabel(BUSINESS_BRAND_FIELD.fieldApiName, 'Business Brand');
    }

    getFieldLabel(fieldApiName, fallback) {
        return this.objectInfo?.fields?.[fieldApiName]?.label || fallback;
    }
}
