branches = [
    {"city": "Minsk", "revenue": 15000},
    {"city": "Warsaw", "revenue": 32000},
    {"city": "London", "revenue": 12000}
]

def audit_logger(func):
    def wrapper(*args, **kwargs):
        print("[AUDIT] Запуск анализа...")
        result = func(*args, **kwargs)
        print("[AUDIT] Анализ завершен.")
        return result
    return wrapper

@audit_logger
def get_sorted_report(branches_data):
    sorted_data = sorted(branches_data, key=lambda x: x['revenue'], reverse=True)
    return sorted_data

sorted_branches = get_sorted_report(branches)

print("Топ филиалов:")
for i, branch in enumerate(sorted_branches, 1):
    print(f"{i}. {branch['city']}: {branch['revenue']}")