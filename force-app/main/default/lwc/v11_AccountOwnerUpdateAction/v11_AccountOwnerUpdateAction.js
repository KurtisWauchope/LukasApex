import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import updateAccountOwner from '@salesforce/apex/V11_AccountOwnerUpdate.updateAccountOwner';

export default class V11_SyncAccountAction extends LightningElement {
    @api recordId;
    @api invoke() {
        updateAccountOwner({ accId: this.recordId });

        const infoToast = new ShowToastEvent({
            title : "Account Owner Update",
            message : "Account Owner Update was triggered.",
            variant : 'info'
        });
        this.dispatchEvent(infoToast);
    }
}