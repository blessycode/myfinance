import csv
import io
from decimal import Decimal
from django.utils import timezone
from apps.transactions.models import Transaction, TransactionType

class ReportExportService:
    @staticmethod
    def generate_csv(user, start_date=None, end_date=None) -> io.StringIO:
        output = io.StringIO()
        writer = csv.writer(output)

        writer.writerow([
            'Transaction ID',
            'Date',
            'Type',
            'Account',
            'Category',
            'Amount',
            'Currency',
            'Description',
            'Merchant',
            'Reversed'
        ])

        qs = Transaction.objects.filter(user=user).select_related('account', 'category')
        if start_date:
            qs = qs.filter(transaction_date__gte=start_date)
        if end_date:
            qs = qs.filter(transaction_date__lte=end_date)

        for t in qs.order_by('-transaction_date'):
            writer.writerow([
                str(t.id),
                t.transaction_date.isoformat(),
                t.transaction_type,
                t.account.name if t.account else '',
                t.category.name if t.category else 'Uncategorized',
                f"{t.amount:.2f}",
                t.currency,
                t.description,
                t.merchant,
                'Yes' if t.is_reversed else 'No'
            ])

        output.seek(0)
        return output

    @staticmethod
    def generate_excel(user, start_date=None, end_date=None) -> io.BytesIO:
        from openpyxl import Workbook
        from openpyxl.styles import Font, PatternFill, Alignment

        wb = Workbook()
        ws = wb.active
        ws.title = "Financial Statement"

        header_font = Font(name="Calibri", size=11, bold=True, color="FFFFFF")
        header_fill = PatternFill(start_color="059669", end_color="059669", fill_type="solid")

        headers = [
            'Date', 'Type', 'Account', 'Category', 'Description', 'Merchant', 'Amount', 'Currency', 'Status'
        ]
        ws.append(headers)

        for col_num in range(1, len(headers) + 1):
            cell = ws.cell(row=1, column=col_num)
            cell.font = header_font
            cell.fill = header_fill
            cell.alignment = Alignment(horizontal="center")

        qs = Transaction.objects.filter(user=user).select_related('account', 'category')
        if start_date:
            qs = qs.filter(transaction_date__gte=start_date)
        if end_date:
            qs = qs.filter(transaction_date__lte=end_date)

        for t in qs.order_by('-transaction_date'):
            ws.append([
                t.transaction_date.isoformat(),
                t.get_transaction_type_display(),
                t.account.name if t.account else '',
                t.category.name if t.category else 'Uncategorized',
                t.description,
                t.merchant,
                float(t.amount),
                t.currency,
                'Reversed' if t.is_reversed else 'Posted'
            ])

        for col in ws.columns:
            max_len = max(len(str(cell.value or '')) for cell in col)
            col_letter = col[0].column_letter
            ws.column_dimensions[col_letter].width = max(max_len + 3, 12)

        output = io.BytesIO()
        wb.save(output)
        output.seek(0)
        return output

    @staticmethod
    def generate_pdf(user, start_date=None, end_date=None) -> io.BytesIO:
        from reportlab.lib.pagesizes import letter
        from reportlab.lib import colors
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle

        buffer = io.BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter, rightMargin=36, leftMargin=36, topMargin=36, bottomMargin=36)
        elements = []
        styles = getSampleStyleSheet()

        title_style = ParagraphStyle(
            'TitleStyle',
            parent=styles['Heading1'],
            fontSize=20,
            textColor=colors.HexColor('#059669'),
            spaceAfter=10
        )
        subtitle_style = ParagraphStyle(
            'SubtitleStyle',
            parent=styles['Normal'],
            fontSize=10,
            textColor=colors.HexColor('#64748B'),
            spaceAfter=15
        )

        elements.append(Paragraph("JIREH Official Statement", title_style))
        period_str = f"Generated on {timezone.now().strftime('%Y-%m-%d %H:%M:%S UTC')} for {user.email}"
        elements.append(Paragraph(period_str, subtitle_style))
        elements.append(Spacer(1, 10))

        data = [['Date', 'Type', 'Account', 'Category', 'Description', 'Amount']]
        qs = Transaction.objects.filter(user=user, is_reversed=False).select_related('account', 'category')
        if start_date:
            qs = qs.filter(transaction_date__gte=start_date)
        if end_date:
            qs = qs.filter(transaction_date__lte=end_date)

        for t in qs.order_by('-transaction_date')[:150]:
            data.append([
                str(t.transaction_date),
                t.get_transaction_type_display(),
                t.account.name[:14] if t.account else '',
                t.category.name[:14] if t.category else 'General',
                t.description[:25],
                f"{t.currency} {t.amount:,.2f}"
            ])

        t_table = Table(data, colWidths=[65, 60, 95, 95, 140, 85])
        t_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#059669')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('ALIGN', (-1, 0), (-1, -1), 'RIGHT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 9),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 6),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#E2E8F0')),
            ('FONTSIZE', (0, 1), (-1, -1), 8),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F8FAFC')])
        ]))

        elements.append(t_table)
        doc.build(elements)
        buffer.seek(0)
        return buffer
