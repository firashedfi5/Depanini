import 'package:depanini/models/feedback_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedbackItem extends StatelessWidget {
  final FeedbackModel feedback;

  const FeedbackItem({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    feedback.username,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd MMM yyyy').format(feedback.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(feedback.comment),
            ],
          ),
        ),
      ),
    );
  }
}
