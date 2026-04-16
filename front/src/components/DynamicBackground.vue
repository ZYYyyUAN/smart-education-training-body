<template>
  <Particles id="tsparticles" :options="particlesOptions" />
</template>

<script setup>
const particlesOptions = {
  fullScreen: { enable: false },
  background: {
    color: {
      value: "transparent"
    }
  },
  fpsLimit: 60,
  interactivity: {
    events: {
      onHover: {
        enable: true,
        mode: ["grab", "bubble"]
      },
      onClick: {
        enable: true,
        mode: "push"
      },
      resize: true
    },
    modes: {
      grab: {
        distance: 140,
        links: {
          opacity: 0.8
        }
      },
      bubble: {
        distance: 200,
        size: 8,
        duration: 2,
        opacity: 0.8
      },
      push: {
        quantity: 3
      },
      repulse: {
        distance: 150,
        duration: 0.4
      }
    }
  },
  particles: {
    number: {
      value: 35,
      density: {
        enable: true,
        area: 1000
      }
    },
    color: {
      value: ["#ffffff", "#e0f2fe", "#bfdbfe", "#dbeafe", "#c7d2fe"]
    },
    shape: {
      type: ["circle", "triangle"],
      options: {
        triangle: {
          nb_sides: 3
        }
      }
    },
    opacity: {
      value: {
        min: 0.3,
        max: 0.7
      },
      random: true,
      animation: {
        enable: true,
        speed: 1.5,
        minimumValue: 0.2,
        sync: false
      }
    },
    size: {
      value: {
        min: 1,
        max: 4
      },
      random: true,
      animation: {
        enable: true,
        speed: 2,
        minimumValue: 0.5,
        sync: false
      }
    },
    links: {
      enable: true,
      distance: 120,
      color: "#ffffff",
      opacity: 0.25,
      width: 1,
      triangles: {
        enable: true,
        color: "#ffffff",
        opacity: 0.1
      }
    },
    move: {
      enable: true,
      speed: {
        min: 0.5,
        max: 1.2
      },
      direction: "none",
      random: true,
      straight: false,
      outModes: {
        default: "bounce"
      },
      attract: {
        enable: false,
        rotateX: 600,
        rotateY: 1200
      }
    }
  },
  detectRetina: true
};
</script>

<style scoped>
#tsparticles {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: -1;
  pointer-events: auto;
  opacity: 0.6;
  transition: opacity 0.3s ease;
}

#tsparticles:hover {
  opacity: 0.8;
}

</style>
