local k = import "k.libsonnet";

local params = {
  version: "v1beta2",
  name: "appName",
  containerPort: 80,
  image: "nginx:latest",
  labels: {app: "customName"},
};

local dsVersion = params.version;

local container = function(version, name, image, containerPort)
  local ds = k.apps[version].daemonSet;

  local containersType = ds.mixin.spec.template.spec.containersType;
  local portsType = containersType.portsType;

  local port = portsType.withContainerPort(containerPort);

  containersType
    .withName(name)
    .withImage(image)
    .withPorts(port);

local createDaemonSet = function(version, name, containers, podLabels={})
  local ds = k.apps[version].daemonSet;

  local labels = {app: name} + podLabels;
  local metadata = ds.mixin.metadata.withName(name);
  local spec = ds.mixin.spec;
  local templateSpec = spec.template.spec.withContainers(containers);
  local templateMetadata = spec.template.metadata.withLabels(labels);

  ds
    .new()
    + metadata
    + spec
    + templateSpec
    + templateMetadata;


local containers = [
  container(dsVersion, params.name, params.image, params.containerPort),
];

local ds = createDaemonSet(
  dsVersion,
  params.name,
  containers,
  podLabels=params.labels);

k.core.v1.list.new([ds])
