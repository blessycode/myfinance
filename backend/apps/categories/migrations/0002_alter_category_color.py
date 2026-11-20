from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('categories', '0001_initial')]

    operations = [
        migrations.AlterField(
            model_name='category',
            name='color',
            field=models.CharField(default='#5B5FF5', max_length=20),
        ),
    ]
