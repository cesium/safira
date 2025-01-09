export const SpotlightBanner = {
    mounted() {
      const banner = this.el;
      
      if (banner) {
        setTimeout(() => {
          banner.style.transition = "top 0.5s ease-in-out";
          banner.style.top = "0";
        }, 500);//inves de 500 segundos meter o tempo do s+potlight ver no timer o que ele recebe
          
          // dar hiden depois de passar o tempo
        setTimeout(() => {
          banner.style.transition = "top 0.5s ease-in-out";
          banner.style.top = "-100px";
        }, 5500);
      }
    }
};  