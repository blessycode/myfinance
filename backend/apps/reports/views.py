from django.http import HttpResponse
from rest_framework import views, permissions, status
from drf_spectacular.utils import extend_schema, OpenApiParameter
from .services import ReportExportService

class ExportReportView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        summary="Export statement records as CSV, Excel, or PDF",
        parameters=[
            OpenApiParameter('format', str, description="csv, excel, or pdf (default: csv)"),
            OpenApiParameter('start_date', str, description="Filter from YYYY-MM-DD"),
            OpenApiParameter('end_date', str, description="Filter to YYYY-MM-DD"),
        ]
    )
    def get(self, request):
        export_format = request.query_params.get('format', 'csv').lower()
        start_date = request.query_params.get('start_date')
        end_date = request.query_params.get('end_date')

        if export_format == 'csv':
            content = ReportExportService.generate_csv(request.user, start_date, end_date)
            response = HttpResponse(content.getvalue(), content_type='text/csv')
            response['Content-Disposition'] = 'attachment; filename="transactions_statement.csv"'
            return response
        elif export_format == 'excel':
            content = ReportExportService.generate_excel(request.user, start_date, end_date)
            response = HttpResponse(
                content.getvalue(),
                content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            )
            response['Content-Disposition'] = 'attachment; filename="transactions_statement.xlsx"'
            return response
        elif export_format == 'pdf':
            content = ReportExportService.generate_pdf(request.user, start_date, end_date)
            response = HttpResponse(content.getvalue(), content_type='application/pdf')
            response['Content-Disposition'] = 'attachment; filename="transactions_statement.pdf"'
            return response

        return HttpResponse("Unsupported export format", status=status.HTTP_400_BAD_REQUEST)
