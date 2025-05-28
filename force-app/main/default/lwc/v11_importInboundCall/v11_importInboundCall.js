import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import importFailedCall from '@salesforce/apex/V11_importFailedCalls.importFailedCall';

export default class V11_importInboundCall extends LightningElement {
    @api recordId;
    @api invoke() {
        importFailedCall({ ibcID: this.recordId });

        const infoToast = new ShowToastEvent({
            title : "Inbound Call",
            message : "Inbound Call was imported.",
            variant : 'info'
        });
        this.dispatchEvent(infoToast);
    }
}