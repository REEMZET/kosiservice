class BookingModel {
  String bookingdate, paymentoption, bookingtime, servicetitle, bookingqty, serimg,
      bookingtotalprice, bookingid, bookingstatus, bookingaddress, bookinglocation,
      bookingslot, username, userphone, userid, userdeviceid, serviceperson,
      serviceid, servicecat, bookingkey, transcationid;

  BookingModel({
    required this.bookingdate,
    required this.paymentoption,
    required this.bookingtime,
    required this.servicetitle,
    required this.bookingqty,
    required this.serimg,
    required this.bookingtotalprice,
    required this.bookingid,
    required this.bookingstatus,
    required this.bookingaddress,
    required this.bookinglocation,
    required this.bookingslot,
    required this.username,
    required this.userphone,
    required this.userid,
    required this.userdeviceid,
    required this.serviceperson,
    required this.serviceid,
    required this.servicecat,
    required this.bookingkey,
    required this.transcationid,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingdate': bookingdate,
      'paymentoption': paymentoption,
      'bookingtime': bookingtime,
      'servicetitle': servicetitle,
      'bookingqty': bookingqty,
      'serimg': serimg,
      'bookingtotalprice': bookingtotalprice,
      'bookingid': bookingid,
      'bookingstatus': bookingstatus,
      'bookingaddress': bookingaddress,
      'bookinglocation': bookinglocation,
      'bookingslot': bookingslot,
      'username': username,
      'userphone': userphone,
      'userid': userid,
      'userdeviceid': userdeviceid,
      'serviceperson': serviceperson,
      'serviceid': serviceid,
      'servicecat': servicecat,
      'bookingkey': bookingkey,
      'transcationid': transcationid,
    };
  }
}