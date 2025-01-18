import "../../vendor/credential-scene";

export const CredentialScene = {
    mounted() {
        window.initializeScene(this.el, this.el.dataset.attendee_name);
    }
};
