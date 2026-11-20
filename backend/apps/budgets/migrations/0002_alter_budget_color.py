from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('budgets', '0001_initial')]

    operations = [
        migrations.AlterField(
            model_name='budget',
            name='color',
            field=models.CharField(default='#5B5FF5', max_length=20),
        ),
    ]
