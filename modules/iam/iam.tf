resource "aws_iam_role" "eks_control_plane_iam_role" {
  name = "${var.cluster_name}-control-plane-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  count      = length(var.eks_control_arns)
  role       = aws_iam_role.eks_control_plane_iam_role.name
  policy_arn = element(var.eks_control_arns, count.index)
}

resource "aws_iam_role" "eks_worker_node_iam_role" {
  name = "${var.cluster_name}-eks-worker-node-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment" {
  count      = length(var.worker_node_arns)
  policy_arn = element(var.worker_node_arns, count.index)
  role       = aws_iam_role.eks_worker_node_iam_role.name
}

resource "aws_iam_instance_profile" "eks_control_plane_profile" {
  name = "eks-control-plane-profile"
  role = aws_iam_role.eks_control_plane_iam_role.name
}

resource "aws_iam_instance_profile" "eks_worker_node_profile" {
  name = "eks-worker-node-profile"
  role = aws_iam_role.eks_worker_node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment_2" {
  count      = var.enable_alb ? 1 : 0
  policy_arn = aws_iam_policy.eks_worker_node_alb_controller[0].arn
  role       = aws_iam_role.eks_worker_node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment_3" {
  count      = var.enable_exdns && var.enable_alb ? 1 : 0
  policy_arn = aws_iam_policy.eks_worker_node_alb_controller_autodns[0].arn
  role       = aws_iam_role.eks_worker_node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment_4" {
  count      = var.enable_autoscaler ? 1 : 0
  policy_arn = aws_iam_policy.eks_worker_node_autoscaler[0].arn
  role       = aws_iam_role.eks_worker_node_iam_role.name
}

resource "aws_iam_policy" "eks_worker_node_autoscaler" {
  count       = var.enable_autoscaler ? 1 : 0
  name        = "eks-worker-node-autoscaler"
  path        = "/"
  description = "Allow cluster-autoscaler pod to scale-in/out underlying ASG"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_policy" "eks_worker_node_alb_controller" {
  count       = var.enable_alb ? 1 : 0
  name        = "eks-worker-node-alb-ingress-controller"
  path        = "/"
  description = "Allow nodes to create/manage ALB Ingress controller API requests"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "eks_worker_node_alb_controller_autodns" {
  count       = var.enable_exdns && var.enable_alb ? 1 : 0
  name        = "eks-worker-node-alb-ingress-controller-autodns"
  path        = "/"
  description = "Allow nodes to create/manage ALB Ingress controller API requests"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
 ]
}
EOF

}

