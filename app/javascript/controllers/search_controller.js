import { Controller } from "@hotwired/stimulus"
// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["params"]

  connect() {
    const value = this.paramsTarget.value;

    fetch(`/books/search?search=${value}`, {
      headers: {
        "Content-Type": "application/json",
      }
    })
    .then((response) => response.text())
    .then(res => {
      const infinityScroll = document.getElementById("infinity_scroll")
      if(infinityScroll!==null) infinityScroll.remove();

      const searchResults = document.getElementById("search_results")
      searchResults.textContent = ''
      searchResults.insertAdjacentHTML('beforeend', res)
    })
  }
}
