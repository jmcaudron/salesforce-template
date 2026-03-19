import { createElement } from 'lwc';
import ContactPointTypeConsentForm from 'c/contactPointTypeConsentForm';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

jest.mock(
    'lightning/uiObjectInfoApi',
    () => {
        const { createLdsTestWireAdapter } = require('@salesforce/wire-service-jest-util');
        return {
            getObjectInfo: createLdsTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

const flushPromises = () => Promise.resolve();

function createComponent() {
    const element = createElement('c-contact-point-type-consent-form', {
        is: ContactPointTypeConsentForm
    });
    element.consent = {
        id: '0XC000000000001',
        name: 'Consent A',
        recordUrl: '/lightning/r/ContactPointTypeConsent/0XC000000000001/view',
        active: true,
        dataUsePurpose: 'Marketing',
        businessBrand: 'Brand A'
    };
    document.body.appendChild(element);
    return element;
}

describe('c-contact-point-type-consent-form', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders fallback labels when object info is unavailable', async () => {
        const element = createComponent();
        await flushPromises();

        const labels = Array.from(element.shadowRoot.querySelectorAll('.field-label')).map((node) =>
            node.textContent.trim()
        );

        expect(labels).toEqual([
            'Name :',
            'Privacy Consent Status :',
            'Data Use Purpose :',
            'Business Brand :'
        ]);
    });

    it('uses metadata labels from object info when available', async () => {
        const element = createComponent();

        getObjectInfo.emit({
            fields: {
                Name: { label: 'Nom' },
                PrivacyConsentStatus: { label: 'Actif' },
                DataUsePurposeId: { label: 'Finalite' },
                BusinessBrandId: { label: 'Marque' }
            }
        });
        await flushPromises();

        const labels = Array.from(element.shadowRoot.querySelectorAll('.field-label')).map((node) =>
            node.textContent.trim()
        );

        expect(labels).toEqual(['Nom :', 'Actif :', 'Finalite :', 'Marque :']);
    });

    it('renders consent details and checkbox state', async () => {
        const element = createComponent();
        await flushPromises();

        const formattedUrl = element.shadowRoot.querySelector('lightning-formatted-url');
        const statusCheckbox = element.shadowRoot.querySelector('lightning-input');
        const valueSpans = element.shadowRoot.querySelectorAll('.field-row > span:not(.field-label)');

        expect(formattedUrl.label).toBe('Consent A');
        expect(formattedUrl.value).toBe('/lightning/r/ContactPointTypeConsent/0XC000000000001/view');
        expect(statusCheckbox.checked).toBe(true);
        expect(statusCheckbox.disabled).toBe(true);
        expect(valueSpans[0].textContent.trim()).toBe('Marketing');
        expect(valueSpans[1].textContent.trim()).toBe('Brand A');
    });
});
