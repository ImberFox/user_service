function deleteFilm(id) {
  $.ajax({
      type: 'DELETE',
      url: '/delete_film/' + id.toString(),
  }).done(function(resp) {
    $.notify("Film Deleted, you whill be redirected");
    setTimeout(function() {
      window.location.href = '/';
    }, 2000);
  }).fail(function(err) {
      console.log(err);
 });
};
