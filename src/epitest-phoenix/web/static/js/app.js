// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

document.addEventListener("DOMContentLoaded", function() {
  initialize()
})

function initialize() {
  let total = 0
  let elems = ["passed", "fail_nocrash", "fail_crash"]
  for (let i = 0; i < elems.length; i++) {
    let elem = document.getElementById("data_" + elems[i])
    total += parseInt(elem.textContent)
  }

  let percent = total/100
  let max_height = 90

  setTimeout(function() {
    for (let i = 0; i < elems.length; i++) {
      let elem = document.getElementById("bar_" + elems[i])
      let data = document.getElementById("data_" + elems[i])
      let value = parseInt(data.textContent)
      let height = (value / total) * 100
      elem.style.height = height + "%"
      let footnote = document.createElement("div")
      footnote.innerHTML = (Math.round(height*10)/10) + "%"
      data.parentNode.appendChild(footnote)
    }
  }, 200)
}

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
