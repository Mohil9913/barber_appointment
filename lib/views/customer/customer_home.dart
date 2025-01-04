import 'package:barber_appointment/controllers/customer_controller.dart';
import 'package:barber_appointment/controllers/profile_setup_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerHome extends StatelessWidget {
  CustomerHome({super.key});

  final ProfileSetupController profileSetupController =
      Get.find<ProfileSetupController>();
  final CustomerController customerController = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: customerController.fetchAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Barber Appointment'),
              actions: [
                Obx(
                  () => IconButton(
                    onPressed: () {
                      customerController.showCustomerData(context);
                    },
                    icon: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.purpleAccent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: customerController.imageUrl.value == ''
                            ? AssetImage(
                                'assets/images/login_screen/customer.jpeg',
                              )
                            : CachedNetworkImageProvider(
                                customerController.imageUrl.value,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: Obx(
              () => FloatingActionButton(
                onPressed: () {
                  Get.toNamed('/new_appointment');
                },
                child: customerController.isLoading.value
                    ? CupertinoActivityIndicator()
                    : Icon(Icons.note_add_outlined),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListView.builder(
                itemCount: customerController.appointmentsInFirebase.length,
                itemBuilder: (context, index) {
                  final appointment =
                      customerController.appointmentsInFirebase[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String>(
                                  future: customerController
                                      .fetchShopName(appointment['shopId']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text('Loading...');
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Text(
                                        snapshot.data ?? 'No Shop Found',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      );
                                    }
                                  },
                                ),
                                Divider(),
                                FutureBuilder<String>(
                                  future: customerController.fetchEmployeeName(
                                      appointment['employeeId']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text('Loading...');
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Text(
                                        'Berber: ${snapshot.data}' ??
                                            'No Employee Found',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 10),
                                Text(
                                    'Date: ${customerController.formatFirebaseTimestamp(appointment['date'])}'),
                                SizedBox(height: 10),
                                ...[
                                  SizedBox(height: 5),
                                  Wrap(
                                    spacing: 5.0,
                                    runSpacing: 5.0,
                                    children: List<Widget>.generate(
                                      appointment['services'].length,
                                      (skillIndex) => Text(
                                        appointment['services'][skillIndex],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text('₹ ${appointment['amount']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
