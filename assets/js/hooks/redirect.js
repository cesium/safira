export const Redirect = {
    mounted() {
        this.handleEvent("redirect", data => {
            console.log(data)
            setTimeout(() => {
                window.location.href = data.url;
            }, data.time);
        });
    }
}