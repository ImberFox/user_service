// $(document).ready(function() {
//    $('.film_rating').click(function() {
//      console.log('1');
//        var aid = $(this).data('aid');
//        // var csrftoken = jQuery("[name=csrfmiddlewaretoken]").val();
//        // if (csrftoken == null)
//            // csrftoken = Cookies.get('csrftoken'); // read from input csrftoken
//        var value =$(this).prop("value").toString();
//        var id = $(this).data('film_id').toString();
//        console.log(id);
//        $.ajax({
//            type: 'POST',
//            url: '/set_rating',
//            contentType: "application/json; charset=utf-8",
//            dataType: "json",
//            // headers: { "X-CSRFToken": csrftoken},
//            data: JSON.stringify({filmId: id, filmRating: value}),
//        }).done(function(resp)
//        {
//          var el = document.getElementById("dr_" + id);
//          el.innerHTML = resp['filmAvgRating'];
//        }).fail(function(err) {
//          var el = document.getElementById("rate" + id);
//          console.log(el);
//          el.innerHTML = "<div style=\"color: red;\"> Sorry: Error on Service, try set rating later </div>" ;
//          // var notification = new Notification('Notification title', {
//            // icon: 'http://cdn.sstatic.net/stackexchange/img/logos/so/so-icon.png',
//            // body: "Hey there! You've been notified!",
//          // });
//
//            console.log(err);
//        });
//    });
// });
