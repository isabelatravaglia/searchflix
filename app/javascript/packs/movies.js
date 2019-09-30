const loadMore = () => {
      const loadMore = document.querySelector('a.load-more');
      const loading = document.querySelector('.loading-gif');
      loading.style.display="none";

        loadMore.addEventListener('click', (event) => {
          event.preventDefault();
          event.currentTarget.setAttribute("disabled", "");

            loadMore.style.display="none";
            loading.style.display="block";

            var lastId = document.querySelector('.container').lastChild.previousElementSibling.dataset.id;

            const url = new URL (event.target.href), params = {id: lastId}
            Object.keys(params).forEach(key => url.searchParams.append(key, params[key]))
            const moviesContainer = document.querySelector('.container');

            fetch(url)
            .then(response => response.json())
            .then((data) => {
              moviesContainer.insertAdjacentHTML('beforeEnd', data.movies);
            })
            .then( () => {
              loadMore.style.display="block"
              loading.style.display="none"
            }
            )
      });
  };
export { loadMore };
