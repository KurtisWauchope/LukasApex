import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import resendObject from '@salesforce/apex/V11_CallComarchOutboundCalls.resendObject';

export default class V11_sendOutboundCall extends LightningElement {
    @api recordId;
    @api invoke() {
        resendObject({ obcId: this.recordId });

        const infoToast = new ShowToastEvent({
            title : "Outbound Call",
            message : "Outbound Call was sent",
            variant : 'info'
        });
        this.dispatchEvent(infoToast);
    }
}