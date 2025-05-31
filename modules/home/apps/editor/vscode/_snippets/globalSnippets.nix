{
  fixme = {
    body = ["$LINE_COMMENT FIXME: $0"];
    description = "Insert a FIXME remark";
    prefix = ["fixme"];
  };
  todo = {
    body = ["$LINE_COMMENT TODO: $0"];
    description = "Insert a TODO remark";
    prefix = ["todo"];
  };
  hold = {
    body = ["$LINE_COMMENT HOLD: $0"];
    description = "Insert a HOLD remark";
    prefix = ["hold"];
  };
}
