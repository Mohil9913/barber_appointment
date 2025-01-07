import 'package:barber_appointment/controllers/customer_controller.dart';
import 'package:barber_appointment/widgets/appointment_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerHome extends StatelessWidget {
  CustomerHome({super.key});

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
          final activeAppointments = customerController.appointmentsInFirebase
              .where((appointment) => appointment['status'] == true)
              .toList();

          final previousAppointments = customerController.appointmentsInFirebase
              .where((appointment) => appointment['status'] == false)
              .toList();

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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (activeAppointments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Active Appointments',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ...activeAppointments.map(
                      (appointment) => AppointmentCard(
                        appointment: appointment,
                        isBarber: false,
                      ),
                    ),
                    if (previousAppointments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Previous Appointments',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ...previousAppointments
                        .map((appointment) => AppointmentCard(
                              appointment: appointment,
                              isBarber: false,
                            )),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
