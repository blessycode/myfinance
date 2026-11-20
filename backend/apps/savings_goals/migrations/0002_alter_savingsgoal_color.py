from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('savings_goals', '0001_initial')]

    operations = [
        migrations.AlterField(
            model_name='savingsgoal',
            name='color',
            field=models.CharField(default='#5B5FF5', max_length=20),
        ),
    ]
