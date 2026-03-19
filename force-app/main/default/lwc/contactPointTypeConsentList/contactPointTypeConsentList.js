import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { gql, graphql } from 'lightning/graphql';

const ACCOUNT_FIELDS = ['Account.PersonIndividualId'];

const CPTC_QUERY = gql`
    query cptcByIndividual($individualId: ID!) {
        uiapi {
            query {
                ContactPointTypeConsent(
                    where: { PartyId: { eq: $individualId } }
                    first: 50
                    orderBy: { Name: { order: ASC } }
                ) {
                    edges {
                        node {
                            Id
                            Name {
                                value
                            }
                            PrivacyConsentStatus {
                                value
                            }
                            DataUsePurpose {
                                Name {
                                    value
                                }
                            }
                            BusinessBrand {
                                Name {
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }
    }
`;

export default class ContactPointTypeConsentList extends NavigationMixin(LightningElement) {
    @api recordId;
    viewAllLabel = 'View All';

    errorMessage;
    personIndividualId;
    consents = [];
    isLoading = true;

    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    wiredAccount({ data, error }) {
        if (error) {
            this.errorMessage = 'Impossible de charger le compte.';
            this.personIndividualId = null;
            this.consents = [];
            this.isLoading = false;
            return;
        }

        if (data) {
            this.personIndividualId = data.fields?.PersonIndividualId?.value || null;
            this.errorMessage = null;
            if (!this.personIndividualId) {
                this.consents = [];
                this.isLoading = false;
            }
        }
    }

    @wire(graphql, {
        query: CPTC_QUERY,
        variables: '$graphqlVariables'
    })
    wiredConsents({ data, errors }) {
        if (!this.personIndividualId) {
            return;
        }

        if (errors && errors.length > 0) {
            this.consents = [];
            this.errorMessage = `Impossible de charger les consentements Contact Point Type. ${this.formatGraphqlErrors(errors)}`;
            this.isLoading = false;
            return;
        }

        if (data) {
            const edges = data.uiapi?.query?.ContactPointTypeConsent?.edges || [];
            this.consents = edges.map((edge) => {
                const node = edge.node;
                return {
                    id: node.Id,
                    name: node.Name?.value || '',
                    recordUrl: `/lightning/r/ContactPointTypeConsent/${node.Id}/view`,
                    active: node.PrivacyConsentStatus?.value === 'OptIn',
                    dataUsePurpose: node.DataUsePurpose?.Name?.value || '',
                    businessBrand: node.BusinessBrand?.Name?.value || ''
                };
            });

            this.errorMessage = null;
            this.isLoading = false;
        }
    }

    get graphqlVariables() {
        if (!this.personIndividualId) {
            return undefined;
        }

        return {
            individualId: this.personIndividualId
        };
    }

    formatGraphqlErrors(errors) {
        return errors.map((e) => e.message).join(', ');
    }

    get hasConsents() {
        return this.consents.length > 0;
    }

    get title() {
        return 'Contact Point Type Consents';
    }

    get showNoIndividualMessage() {
        return !this.isLoading && !this.personIndividualId && !this.errorMessage;
    }

    get showNoConsentMessage() {
        return !this.isLoading && this.personIndividualId && !this.errorMessage && !this.hasConsents;
    }

    handleViewAll() {
        if (!this.personIndividualId) {
            return;
        }

        this[NavigationMixin.Navigate](
            {
                type: 'standard__recordRelationshipPage',
                attributes: {
                    recordId: this.personIndividualId,
                    objectApiName: 'Individual',
                    relationshipApiName: 'Individuals',
                    actionName: 'view'
                }
            },
            false
        );
    }
}
