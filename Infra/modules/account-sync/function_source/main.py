import functions_framework

@functions_framework.http
def scheduled_function_handler(request):
    """
    HTTP Cloud Function that is triggered by Cloud Scheduler.
    """
    print("Function was triggered by Cloud Scheduler.")
    # Add your desired logic here
    return "OK", 200