from decimal import Decimal, ROUND_HALF_UP

def round_money(amount: Decimal | str | int | float, precision: int = 2) -> Decimal:
    """
    Safely rounds monetary figures using financial standard ROUND_HALF_UP.
    Never use floats directly in financial logic.
    """
    if isinstance(amount, float):
        amount = str(amount)
    d = Decimal(str(amount))
    exponent = Decimal('10') ** -precision
    return d.quantize(exponent, rounding=ROUND_HALF_UP)
