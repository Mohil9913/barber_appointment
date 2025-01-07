import 'package:barber_appointment/controllers/barber_appointment_controller.dart';
import 'package:barber_appointment/widgets/appointment_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BarberHome extends StatelessWidget {
  BarberHome({super.key});

  final BarberAppointmentController barberAppointmentController =
      Get.find<BarberAppointmentController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: barberAppointmentController.fetchAppointments(),
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
          return Obx(() {
            final activeAppointments = barberAppointmentController
                .appointmentsInFirebase
                .where((appointment) => appointment['status'] == true)
                .toList();

            final previousAppointments = barberAppointmentController
                .appointmentsInFirebase
                .where((appointment) => appointment['status'] == false)
                .toList();

            return Scaffold(
              appBar: AppBar(
                title: Text('Appointment Dashboard'),
                actions: [
                  Obx(
                    () => IconButton(
                      onPressed: () {
                        barberAppointmentController.showBarberData(context);
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
                          backgroundImage:
                              barberAppointmentController.imageUrl.value == ''
                                  ? AssetImage(
                                      'assets/images/login_screen/barber.jpeg',
                                    )
                                  : CachedNetworkImageProvider(
                                      barberAppointmentController
                                          .imageUrl.value,
                                    ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Get.toNamed('/manage_shops');
                },
                child: Icon(CupertinoIcons.scissors_alt),
              ),
              body: RefreshIndicator(
                onRefresh: () {
                  return barberAppointmentController.fetchAppointments();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Active appointments section
                        if (activeAppointments.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Active Appointments',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ...activeAppointments.map(
                          (appointment) => InkWell(
                            onTap: () {
                              barberAppointmentController.markCompleted(
                                  barberAppointmentController
                                      .appointmentsInFirebase
                                      .indexOf(appointment));
                            },
                            child: AppointmentCard(
                              appointment: appointment,
                              isBarber: true,
                            ),
                          ),
                        ),

                        // Previous appointments section
                        if (previousAppointments.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Previous Appointments',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ...previousAppointments
                            .map((appointment) => AppointmentCard(
                                  appointment: appointment,
                                  isBarber: true,
                                )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        }
      },
    );
  }
}
