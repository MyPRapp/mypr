# Generated by Django 5.0.7 on 2024-08-01 14:42

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0003_alter_clubs_rating'),
    ]

    operations = [
        migrations.AlterField(
            model_name='bookings',
            name='booked_at',
            field=models.DateTimeField(),
        ),
    ]
