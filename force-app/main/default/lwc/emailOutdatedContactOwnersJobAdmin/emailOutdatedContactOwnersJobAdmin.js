import { LightningElement, track } from 'lwc';
import getJobStatus from '@salesforce/apex/EmailOutdatedContactOwnersJobController.getJobStatus';
import scheduleJob from '@salesforce/apex/EmailOutdatedContactOwnersJobController.scheduleJob';
import unscheduleJob from '@salesforce/apex/EmailOutdatedContactOwnersJobController.unscheduleJob';

import sendNow from '@salesforce/apex/EmailOutdatedContactOwnersJobController.sendNow';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EmailOutdatedContactOwnersJobAdmin extends LightningElement {
    @track jobStatus = null;
    @track cronExpression = '';
    @track errorMessage = '';

    connectedCallback() {
        this._loadJobStatus();
    }

    get isScheduleDisabled() {
        return !this.cronExpression.trim();
    }

    get isUnscheduleDisabled() {
        return !this.jobStatus;
    }

    handleCronChange(event) {
        this.cronExpression = event.target.value;
        this.errorMessage = '';
    }

    handleSchedule() {
        this.errorMessage = '';
        scheduleJob({ cronExpression: this.cronExpression })
            .then(() => this._loadJobStatus())
            .catch(error => {
                this.errorMessage = error?.body?.message ?? 'Failed to schedule job.';
            });
    }

    handleUnschedule() {
        this.errorMessage = '';
        unscheduleJob()
            .then(() => {
                this.jobStatus = null;
            })
            .catch(error => {
                this.errorMessage = error?.body?.message ?? 'Failed to unschedule job.';
            });
    }

    handleSendNow() {
        sendNow()
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Email sent successfully.',
                        variant: 'success'}));
            })
            .catch(error => {
                this.errorMessage = error?.body?.message ?? 'Failed to send email.';
            });
    }

    _loadJobStatus() {
        getJobStatus()
            .then(result => {
                this.jobStatus = result;
                if (result) {
                    this.cronExpression = result.cronExpression;
                }
            })
            .catch(error => {
                this.errorMessage = error?.body?.message ?? 'Failed to load job status.';
            });
    }
}
