String checkStatusCode(int statusCode) {
  if (statusCode == 400) {
    return "bad_request";
  } else if (statusCode == 401) {
    return "unauthorized";
  } else if (statusCode == 402) {
    return "payment_required";
  } else if (statusCode == 403) {
    return "forbidden";
  } else if (statusCode == 404) {
    return "not_found";
  } else if (statusCode == 405) {
    return "method_not_found";
  } else if (statusCode == 408) {
    return "request_timeout";
  } else if (statusCode == 409) {
    return "conflict";
  } else if (statusCode == 410) {
    return "gone";
  } else if (statusCode == 415) {
    return "unsupported_media-type";
  } else if (statusCode >= 500 && statusCode <= 505) {
    return "server_error";
  }
  return "unknown_error";
}
