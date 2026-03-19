import { createElement } from 'lwc';
import ContactPointTypeConsentList from 'c/contactPointTypeConsentList';
import { getRecord } from 'lightning/uiRecordApi';
import { graphql } from 'lightning/graphql';

const mockNavigate = jest.fn();

jest.mock(
    'lightning/navigation',
    () => {
        const Navigate = Symbol('Navigate');
        const NavigationMixin = (Base) =>
            class extends Base {
                [Navigate](pageReference, replace) {
                    mockNavigate(pageReference, replace);
                }
            };

        NavigationMixin.Navigate = Navigate;
        return {
            NavigationMixin
        };
    },
    { virtual: true }
);

jest.mock(
    'lightning/uiRecordApi',
    () => {
        const { createLdsTestWireAdapter } = require('@salesforce/wire-service-jest-util');
        return {
            getRecord: createLdsTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    'lightning/graphql',
    () => {
        const { createTestWireAdapter } = require('@salesforce/wire-service-jest-util');
        return {
            gql: jest.fn((strings, ...values) =>
                strings.reduce((accumulator, part, index) => accumulator + part + (values[index] || ''), '')
            ),
            graphql: createTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

const flushPromises = () => Promise.resolve();

function createComponent() {
    const element = createElement('c-contact-point-type-consent-list', {
        is: ContactPointTypeConsentList
    });
    element.recordId = '001000000000001AAA';
    document.body.appendChild(element);
    return element;
}

describe('c-contact-point-type-consent-list', () => {
    afterEach(() => {
        mockNavigate.mockClear();
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('starts in loading state', () => {
        const element = createComponent();

        expect(element.shadowRoot.querySelector('lightning-spinner')).not.toBeNull();
    });

    it('handles account load error', async () => {
        const element = createComponent();

        getRecord.error();
        await flushPromises();

        const error = element.shadowRoot.querySelector('.slds-text-color_error');
        expect(error).not.toBeNull();
        expect(error.textContent).toContain('Impossible de charger le compte.');
        expect(element.shadowRoot.querySelector('c-contact-point-type-consent-form')).toBeNull();
    });

    it('shows no-individual message when account has no Individual', async () => {
        const element = createComponent();

        getRecord.emit({
            fields: {
                PersonIndividualId: {
                    value: null
                }
            }
        });
        await flushPromises();

        expect(element.shadowRoot.textContent).toContain("Aucun Individual n'est associé à ce compte.");
    });

    it('ignores graphql results when no individual id exists', async () => {
        const element = createComponent();

        getRecord.emit({
            fields: {
                PersonIndividualId: {
                    value: null
                }
            }
        });

        graphql.emit({
            data: {
                uiapi: {
                    query: {
                        ContactPointTypeConsent: {
                            edges: [
                                {
                                    node: {
                                        Id: '0XC000000000001',
                                        Name: { value: 'Consent A' }
                                    }
                                }
                            ]
                        }
                    }
                }
            }
        });
        await flushPromises();

        expect(element.shadowRoot.querySelectorAll('c-contact-point-type-consent-form')).toHaveLength(0);
        expect(element.shadowRoot.textContent).toContain("Aucun Individual n'est associé à ce compte.");
    });

    it('handles graphql errors', async () => {
        const element = createComponent();

        getRecord.emit({
            fields: {
                PersonIndividualId: {
                    value: '0PK000000000001'
                }
            }
        });
        graphql.emit({
            errors: [{ message: 'Error A' }, { message: 'Error B' }]
        });
        await flushPromises();

        const error = element.shadowRoot.querySelector('.slds-text-color_error');
        expect(error).not.toBeNull();
        expect(error.textContent).toContain('Impossible de charger les consentements Contact Point Type.');
        expect(error.textContent).toContain('Error A, Error B');
    });

    it('maps graphql consent data and renders child forms', async () => {
        const element = createComponent();

        getRecord.emit({
            fields: {
                PersonIndividualId: {
                    value: '0PK000000000001'
                }
            }
        });
        graphql.emit({
            data: {
                uiapi: {
                    query: {
                        ContactPointTypeConsent: {
                            edges: [
                                {
                                    node: {
                                        Id: '0XC000000000001',
                                        Name: { value: 'Consent A' },
                                        PrivacyConsentStatus: { value: 'OptIn' },
                                        DataUsePurpose: { Name: { value: 'Marketing' } },
                                        BusinessBrand: { Name: { value: 'Brand A' } }
                                    }
                                },
                                {
                                    node: {
                                        Id: '0XC000000000002',
                                        Name: { value: 'Consent B' },
                                        PrivacyConsentStatus: { value: 'OptOut' },
                                        DataUsePurpose: { Name: { value: 'Support' } },
                                        BusinessBrand: { Name: { value: 'Brand B' } }
                                    }
                                }
                            ]
                        }
                    }
                }
            }
        });
        await flushPromises();

        const forms = element.shadowRoot.querySelectorAll('c-contact-point-type-consent-form');
        expect(forms).toHaveLength(2);

        expect(forms[0].consent).toEqual({
            id: '0XC000000000001',
            name: 'Consent A',
            recordUrl: '/lightning/r/ContactPointTypeConsent/0XC000000000001/view',
            active: true,
            dataUsePurpose: 'Marketing',
            businessBrand: 'Brand A'
        });
        expect(forms[1].consent).toEqual({
            id: '0XC000000000002',
            name: 'Consent B',
            recordUrl: '/lightning/r/ContactPointTypeConsent/0XC000000000002/view',
            active: false,
            dataUsePurpose: 'Support',
            businessBrand: 'Brand B'
        });
    });

    it('shows no-consent message when individual exists but no consent is returned', async () => {
        const element = createComponent();

        getRecord.emit({
            fields: {
                PersonIndividualId: {
                    value: '0PK000000000001'
                }
            }
        });
        graphql.emit({
            data: {
                uiapi: {
                    query: {
                        ContactPointTypeConsent: {
                            edges: []
                        }
                    }
                }
            }
        });
        await flushPromises();

        expect(element.shadowRoot.textContent).toContain(
            'Aucun Contact Point Type Consent trouvé pour cet Individual.'
        );
    });

    it('navigates on View All when individual id exists', async () => {
        const element = createComponent();

        getRecord.emit({
            fields: {
                PersonIndividualId: {
                    value: '0PK000000000001'
                }
            }
        });
        await flushPromises();

        const button = element.shadowRoot.querySelector('button');
        button.click();

        expect(mockNavigate).toHaveBeenCalledTimes(1);
        expect(mockNavigate).toHaveBeenCalledWith(
            {
                type: 'standard__recordRelationshipPage',
                attributes: {
                    recordId: '0PK000000000001',
                    objectApiName: 'Individual',
                    relationshipApiName: 'Individuals',
                    actionName: 'view'
                }
            },
            false
        );
    });

    it('does not navigate on View All when no individual id exists', async () => {
        const element = createComponent();

        getRecord.emit({
            fields: {
                PersonIndividualId: {
                    value: null
                }
            }
        });
        await flushPromises();

        const button = element.shadowRoot.querySelector('button');
        button.click();

        expect(mockNavigate).not.toHaveBeenCalled();
    });
});
