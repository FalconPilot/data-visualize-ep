/*
**  Initialize
*/

let submit = document.getElementById("form-sub")
submit.addEventListener("click", function() {
  let username = document.getElementById("f-login").value
  let password = document.getElementById("f-pass").value
  request(username, password)
})

/*
**  HTTP Request
*/

function request(username, password) {
  $.ajax({
    url: "http://bugs-data.thomasdufour.fr:2847/0.1/modules",
    type: "POST",
    success: function(data) {
      console.log("Cool !")
    },
    beforeSend: function(xhr) {
      xhr.setRequestHeader("Authorization", "Basic " + btoa(username + ":" + password))
    }
  })
}
