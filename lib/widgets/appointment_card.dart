import 'package:barber_appointment/controllers/barber_appointment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentCard extends StatelessWidget {
  AppointmentCard({
    super.key,
    required this.appointment,
    required this.isBarber,
  });

  final appointment;
  final isBarber;
  final BarberAppointmentController barberAppointmentController =
      Get.find<BarberAppointmentController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: barberAppointmentController
                        .fetchShopName(appointment['shopId']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...');
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          snapshot.data ?? 'No Shop Found',
                          style: Theme.of(context).textTheme.titleMedium,
                        );
                      }
                    },
                  ),
                  Divider(),
                  FutureBuilder<String>(
                    future: barberAppointmentController
                        .fetchEmployeeName(appointment['employeeId']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...');
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          'Barber: ${snapshot.data}',
                          style: Theme.of(context).textTheme.titleSmall,
                        );
                      }
                    },
                  ),
                  if (isBarber) SizedBox(height: 10),
                  if (isBarber)
                    FutureBuilder<String>(
                      future: barberAppointmentController
                          .fetchCustomerName(appointment['customerId']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading...');
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Text(
                            'Customer: ${snapshot.data}',
                            style: Theme.of(context).textTheme.titleSmall,
                          );
                        }
                      },
                    ),
                  SizedBox(height: 10),
                  Text(
                      'Date: ${barberAppointmentController.formatFirebaseTimestamp(appointment['date'])} | ${appointment['timeSlot']}'),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 5.0,
                    runSpacing: 5.0,
                    children: [
                      for (int i = 0;
                          i < appointment['services'].length;
                          i++) ...[
                        if (i == 0) Text('Service(s): '),
                        Text(appointment['services'][i]),
                        if (i < appointment['services'].length - 1) Text('|'),
                        // Separator
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text('₹ ${appointment['amount']}'),
          ],
        ),
      ),
    );
  }
}
