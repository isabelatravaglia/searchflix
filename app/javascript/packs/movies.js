// when the page is ready for manipulation
const loadMore = () => {
  // domReady(function () {
    const loadMore = document.querySelector('.load-more');
      loadMore.addEventListener('click', (event) => {
        event.preventDefault();

          document.querySelector('.load-more').style.display="none";
          document.querySelector('.loading-gif').style.display="block";

          var last_id = document.querySelector('.container').lastChild.previousElementSibling.dataset.id;

          console.log(event.target.href);
          const url = event.target.href;

          fetch(url, {dataType: 'JSON'})
          .then((response) => {console.log(response)}
            )
          .then(data => {
            // id: last_id
            console.log(data);
          })
      //     .then(function () {
      //             document.querySelector('.loading-gif').hide();
      //             document.querySelector('.load-more').show();
    });
  // })
};

export { loadMore };
