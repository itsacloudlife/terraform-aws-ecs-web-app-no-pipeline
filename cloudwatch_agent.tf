resource "aws_iam_role_policy_attachment" "cloudwatch_agent_attach" {
  count      = var.cloudwatch_ecs_agent.enabled ? 1 : 0
  role       = module.ecs_alb_service_task.task_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

locals {
  agent_json = {
    "traces" : {
      "traces_collected" : {
        "application_signals" : {}
      }
    },
    "logs" : {
      "metrics_collected" : {
        "application_signals" : {}
      }
    }
  }
}

resource "aws_ssm_parameter" "cloudwatch_agent" {
  count = var.cloudwatch_ecs_agent.enabled ? 1 : 0
  name  = "ecs-cwagent"
  type  = "String"
  value = local.agent_json
}