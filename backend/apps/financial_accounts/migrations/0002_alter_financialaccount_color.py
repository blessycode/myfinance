from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('financial_accounts', '0001_initial')]

    operations = [
        migrations.AlterField(
            model_name='financialaccount',
            name='color',
            field=models.CharField(default='#2F80ED', max_length=20),
        ),
    ]
