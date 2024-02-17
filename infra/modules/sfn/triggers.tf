/* --------------------------------------------------------
ARQUIVO: triggers.tf @ sfn module

Arquivo responsável por centralizar todos os gatilhos do
Eventbridge para engatilhamento/agendamento de workflows
do Step Functions
-------------------------------------------------------- */

/* -------------------------------------------------------
    TRIGGER
    From: Eventbridge
    To: sfn-dedup-sot-spec-tables
------------------------------------------------------- */


# Definindo regra de execução agendada via Eventbridge
resource "aws_cloudwatch_event_rule" "trigger-pynvest-sfn-dedup-sot-spec-tables" {
  name                = "trigger-${aws_sfn_state_machine.pynvest-sfn-dedup-sot-spec-tables.name}"
  description         = "Regra de execução agendada do workflow Step Functions ${aws_sfn_state_machine.pynvest-sfn-dedup-sot-spec-tables.name}"
  schedule_expression = var.cron_expression_to_start_sfn_workflow
}

# Vinculando regra de agendamento à função
resource "aws_cloudwatch_event_target" "trigger-pynvest-sfn-dedup-sot-spec-tables" {
  arn      = aws_sfn_state_machine.pynvest-sfn-dedup-sot-spec-tables.arn
  rule     = aws_cloudwatch_event_rule.trigger-pynvest-sfn-dedup-sot-spec-tables.name
  role_arn = var.iam_roles_arns_map["pynvest-sfn-invoke-lambda-functions"]

  depends_on = [
    aws_sfn_state_machine.pynvest-sfn-dedup-sot-spec-tables,
    aws_cloudwatch_event_rule.trigger-pynvest-sfn-dedup-sot-spec-tables
  ]
}
