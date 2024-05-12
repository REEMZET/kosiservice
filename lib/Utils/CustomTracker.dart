import 'package:order_tracker_zen/order_tracker_zen.dart';

enum BookingStatus { pending, confirm, outForService, started, serviceDone, canceled }

class TrackerGenerator {
  static List<TrackerData> generateTrackerData(BookingStatus bookingStatus) {
    List<TrackerData> trackerDataList = [];

    switch (bookingStatus) {
      case BookingStatus.pending:
        trackerDataList.add(
          TrackerData(
            title: "📝Booking Pending",
            date: " ",
            tracker_details: [
              TrackerDetails(
                title: "Your Service has booked",
                datetime: "we are checking.please wait for confirmation",
              ),
            ],
          ),
        );
        break;

      case BookingStatus.confirm:
        trackerDataList.add(
          TrackerData(
            title: "📝Booking Pending",
            date: " ",
            tracker_details: [
              TrackerDetails(
                title: "Your Service has booked",
                datetime: "we are checking.please wait for confirmation",
              ),
            ],
          ),
        );
        trackerDataList.add(
          TrackerData(
            title: "✅Booking Confirm",
            date: "",
            tracker_details: [
              TrackerDetails(
                title: "we are searching kosi helper",
                datetime: " ",
              ),
            ],
          ),
        );
        break;

      case BookingStatus.outForService:
        trackerDataList.add(
          TrackerData(
            title: "📝Booking Pending",
            date: "  ",
            tracker_details: [
              TrackerDetails(
                title: "Your Service has booked",
                datetime: "we are checking.please wait for confirmation",
              ),
            ],
          ),
        );
        trackerDataList.add(
          TrackerData(
            title: "✅Booking Confirm",
            date: "",
            tracker_details: [
              TrackerDetails(
                title: "we are searching kosi helper",
                datetime: "  ",
              ),
            ],
          ),
        );
        trackerDataList.add(
          TrackerData(
            title: "🚚Out for Service",
            date: "",
            tracker_details: [
              TrackerDetails(
                title: "Our Kosi helper is on the way to you",
                datetime: "you can guide our kosi helper by calling",
              ),
            ],
          ),
        );
        break;

      case BookingStatus.started:
        trackerDataList.add(
          TrackerData(
            title: "📝Booking Pending",
            date: "  ",
            tracker_details: [
              TrackerDetails(
                title: "Your Service has booked",
                datetime: "we are checking.please wait for confirmation",
              ),
            ],
          ),
        );
        trackerDataList.add(
          TrackerData(
            title: "✅Booking Confirm",
            date: "",
            tracker_details: [
              TrackerDetails(
                title: "we are searching kosi helper",
                datetime: "  ",
              ),
            ],
          ),
        );
        trackerDataList.add(
          TrackerData(
            title: "🚚Out for Service",
            date: "",
            tracker_details: [
              TrackerDetails(
                title: "Our Kosi helper is on the way to you",
                datetime: "you can guide our kosi helper by calling",
              ),
            ],
          ),
        );
        trackerDataList.add(
          TrackerData(
            title: "🛠️Started",
            date: "",
            tracker_details: [
              TrackerDetails(
                title: "Your service has started",
                datetime: "Our Kosi helper is working on your request",
              ),
            ],
          ),
        );
        break;

      case BookingStatus.serviceDone:
        trackerDataList.add(
          TrackerData(
            title: "📝Booking Pending",
            date: "  ",
            tracker_details: [
              TrackerDetails(
                title: "Your Service has booked",
                datetime: "we are checking.please wait for confirmation",
              ),
            ],
          ),
        );
        trackerDataList.add(
          TrackerData(
            title: "✅Booking Confirm",
            date: "",
            tracker_details: [
              TrackerDetails(
                title: "we are searching kosi helper",
                datetime: "  ",
              ),
            ],
          ),
        );
        trackerDataList.add(
          TrackerData(
            title: "🚚Out for Service",
            date: "",
            tracker_details: [
              TrackerDetails(
                title: "Our Kosi helper is on the way to you",
                datetime: "you can guide our kosi helper by calling",
              ),
            ],
          ),
        );
        trackerDataList.add(
          TrackerData(
            title: "🎉Service Done",
            date: "",
            tracker_details: [
              TrackerDetails(
                title: "Thank you for giving this opportunity",
                datetime: "We hope you had a great experience.",
              ),
            ],
          ),
        );
        break;

      case BookingStatus.canceled: // Add case for "Canceled"
        trackerDataList.add(
          TrackerData(
            title: "❌Booking Canceled",
            date: " ",
            tracker_details: [
              TrackerDetails(
                title: "Your booking has been canceled",
                datetime: "We apologize for any inconvenience caused.",
              ),
            ],
          ),
        );
        break;
    }

    return trackerDataList;
  }
}
