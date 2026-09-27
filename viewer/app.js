import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

// Subsystem definitions with palette colors & descriptive metadata
const SUBSYSTEM_CONFIG = {
  stage_body: {
    label: 'Flexure Stage & Body',
    icon: '🏗️',
    color: '#10b981',
    badgeClass: 'badge-stage',
    desc: 'Monolithic parallelogram flexure stage, main body, and slide retention clips.'
  },
  actuators: {
    label: 'Actuators & Kinematics',
    icon: '⚙️',
    color: '#3b82f6',
    badgeClass: 'badge-actuators',
    desc: '3-axis 28BYJ-48 stepper motors, reduction gears, stainless M3 leadscrews & Viton bands.'
  },
  optics: {
    label: 'RMS Optics & Camera',
    icon: '🔬',
    color: '#a855f7',
    badgeClass: 'badge-optics',
    desc: 'DIN/RMS objective, f=50mm tube lens, Pi camera v2 sensor and light-tight tube sleeve.'
  },
  illumination: {
    label: 'Transmitted Illumination',
    icon: '💡',
    color: '#f59e0b',
    badgeClass: 'badge-illumination',
    desc: 'Condenser riser dovetail, quasi-Kohler condenser lens, aperture diaphragm, and LED.'
  },
  base_electronics: {
    label: 'Electronics & Base Stand',
    icon: '⚡',
    color: '#06b6d4',
    badgeClass: 'badge-base_electronics',
    desc: 'Microscope base stand, pull-out drawer, Raspberry Pi 4B, and Sangaboard v0.5.'
  }
};

class ExplodedViewApp {
  constructor() {
    this.container = document.getElementById('canvas-container');
    this.meshMetadata = {};
    this.meshObjects = [];
    this.initialTransforms = [];
    this.tracerLines = null;
    
    this.explodeFactor = 0; // 0 to 1
    this.isAnimatingExplode = false;
    this.animDirection = 1;
    this.renderMode = 'solid'; // 'solid' | 'xray' | 'wireframe'
    this.showTracers = false;
    
    this.subsystemVisibility = {
      stage_body: true,
      actuators: true,
      optics: true,
      illumination: true,
      base_electronics: true
    };
    
    // Cross-section clipping
    this.clipEnabled = false;
    this.clipAxis = 'y';
    this.clipPos = 70;
    this.clipPlane = new THREE.Plane(new THREE.Vector3(0, -1, 0), this.clipPos);

    this.selectedMesh = null;
    this.hoveredMesh = null;
    this.raycaster = new THREE.Raycaster();
    this.mouse = new THREE.Vector2(-999, -999);

    this.initScene();
    this.initUI();
    this.loadData();
    this.setupEvents();
    this.animate();
  }

  initScene() {
    // Scene
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color('#0a0f1d');
    this.scene.fog = new THREE.FogExp2('#0a0f1d', 0.0018);

    // Camera
    this.camera = new THREE.PerspectiveCamera(
      42,
      window.innerWidth / window.innerHeight,
      1,
      2000
    );
    this.camera.position.set(190, 220, 220);

    // Renderer
    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false, powerPreference: 'high-performance' });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.15;
    this.renderer.localClippingEnabled = true;
    this.container.appendChild(this.renderer.domElement);

    // Controls
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;
    this.controls.dampingFactor = 0.05;
    this.controls.target.set(0, 90, 0);
    this.controls.maxPolarAngle = Math.PI / 2 + 0.35; // allow looking slightly from below
    this.controls.minDistance = 30;
    this.controls.maxDistance = 900;

    // Lighting
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.75);
    this.scene.add(ambientLight);

    const hemiLight = new THREE.HemisphereLight(0xddeeff, 0x111827, 0.85);
    hemiLight.position.set(0, 200, 0);
    this.scene.add(hemiLight);

    const keyLight = new THREE.DirectionalLight(0xffffff, 1.8);
    keyLight.position.set(150, 300, 150);
    keyLight.castShadow = true;
    keyLight.shadow.mapSize.width = 2048;
    keyLight.shadow.mapSize.height = 2048;
    keyLight.shadow.camera.near = 50;
    keyLight.shadow.camera.far = 600;
    keyLight.shadow.camera.left = -160;
    keyLight.shadow.camera.right = 160;
    keyLight.shadow.camera.top = 160;
    keyLight.shadow.camera.bottom = -160;
    keyLight.shadow.bias = -0.0003;
    this.scene.add(keyLight);

    const fillLight = new THREE.DirectionalLight(0x38bdf8, 0.7);
    fillLight.position.set(-150, 100, -100);
    this.scene.add(fillLight);

    const rimLight = new THREE.DirectionalLight(0xa78bfa, 0.9);
    rimLight.position.set(0, -100, -200);
    this.scene.add(rimLight);

    // Circular ground contact grid
    const grid = new THREE.GridHelper(360, 36, 0x06b6d4, 0x1e293b);
    grid.position.y = -2;
    this.scene.add(grid);

    // Root Assembly Group
    this.assemblyGroup = new THREE.Group();
    this.scene.add(this.assemblyGroup);
  }

  async loadData() {
    const loadingOverlay = document.getElementById('loading-overlay');
    const loadingSub = document.getElementById('loading-msg');

    try {
      // 1. Fetch metadata
      loadingSub.textContent = 'Loading mechanical component database...';
      const metaRes = await fetch('mesh_metadata.json');
      this.meshMetadata = await metaRes.json();

      // 2. Load GLB model (try local first, fallback to docs or remote)
      loadingSub.textContent = 'Streaming 3D CAD mesh geometry (50 MB)...';
      const gltfLoader = new GLTFLoader();
      
      const glbPaths = [
        'complete_microscope_rms.glb',
        '../docs/gltf/complete_microscope_rms.glb',
        'https://build.openflexure.org/openflexure-microscope/v7.0.0-beta5/gltf/complete_microscope_rms.glb'
      ];

      let gltf = null;
      for (const p of glbPaths) {
        try {
          gltf = await new Promise((resolve, reject) => {
            gltfLoader.load(p, resolve, (xhr) => {
              if (xhr.lengthComputable) {
                const pct = Math.round((xhr.loaded / xhr.total) * 100);
                loadingSub.textContent = `Streaming 3D geometry... ${pct}%`;
              }
            }, reject);
          });
          if (gltf) break;
        } catch (e) {
          console.warn(`Failed loading from ${p}, trying next...`);
        }
      }

      if (!gltf) {
        throw new Error('Unable to load complete_microscope_rms.glb');
      }

      this.processGltf(gltf);

      // Hide loading screen
      loadingOverlay.style.opacity = '0';
      setTimeout(() => { loadingOverlay.style.display = 'none'; }, 500);

    } catch (err) {
      console.error(err);
      loadingSub.innerHTML = `<span style="color: #f43f5e">Error loading 3D model: ${err.message}</span>`;
    }
  }

  processGltf(gltf) {
    let meshIndex = 0;
    this.meshObjects = [];
    this.initialTransforms = [];

    gltf.scene.traverse((child) => {
      if (child.isMesh) {
        const id = meshIndex;
        child.castShadow = true;
        child.receiveShadow = true;

        // Clone material so individual effects, x-ray, and clipping don't bleed
        const originalMat = child.material.clone();
        child.material = originalMat;
        child.material.clippingPlanes = this.clipEnabled ? [this.clipPlane] : [];
        child.material.clipShadows = true;

        child.userData = {
          id: id,
          originalColor: originalMat.color.clone(),
          originalOpacity: originalMat.opacity !== undefined ? originalMat.opacity : 1.0,
          originalTransparent: originalMat.transparent || false,
          meta: this.meshMetadata[String(id)] || {
            name: `Kinematic Component #${id}`,
            subsystem: 'stage_body',
            material: 'PLA 3D-Printed',
            kinematic_role: 'Structural mounting and stage positioning element.',
            vec: [0, 0, 0],
            center: [0, 0, 0],
            size: [10, 10, 10]
          }
        };

        this.meshObjects.push(child);
        this.initialTransforms.push({
          pos: child.position.clone(),
          rot: child.rotation.clone(),
          scale: child.scale.clone()
        });

        meshIndex++;
      }
    });

    this.assemblyGroup.add(gltf.scene);
    this.renderSubsystemList();
    this.updateTracerGeometry();

    // Default select main body (usually index 144)
    const mainBody = this.meshObjects.find(m => m.userData.id === 144) || this.meshObjects[0];
    if (mainBody) this.selectMesh(mainBody);
  }

  setExplode(factor) {
    this.explodeFactor = Math.max(0, Math.min(1, factor));
    document.getElementById('explode-slider').value = (this.explodeFactor * 100).toFixed(1);
    document.getElementById('explode-val-badge').textContent = `${Math.round(this.explodeFactor * 100)}%`;

    for (let i = 0; i < this.meshObjects.length; i++) {
      const mesh = this.meshObjects[i];
      const initial = this.initialTransforms[i];
      const vec = mesh.userData.meta.vec || [0, 0, 0];

      // Smooth kinematic offset along disassembly vector
      mesh.position.x = initial.pos.x + vec[0] * this.explodeFactor;
      mesh.position.y = initial.pos.y + vec[1] * this.explodeFactor;
      mesh.position.z = initial.pos.z + vec[2] * this.explodeFactor;
    }

    if (this.showTracers) {
      this.updateTracerGeometry();
    }
  }

  updateTracerGeometry() {
    if (!this.showTracers) {
      if (this.tracerLines) this.tracerLines.visible = false;
      return;
    }

    const positions = [];
    const colors = [];

    for (let i = 0; i < this.meshObjects.length; i++) {
      const mesh = this.meshObjects[i];
      if (!mesh.visible) continue;
      const initial = this.initialTransforms[i];
      const current = mesh.position;

      const dist = initial.pos.distanceTo(current);
      if (dist > 1.5) {
        positions.push(initial.pos.x, initial.pos.y, initial.pos.z);
        positions.push(current.x, current.y, current.z);

        const sub = mesh.userData.meta.subsystem;
        const colHex = SUBSYSTEM_CONFIG[sub]?.color || '#06b6d4';
        const c = new THREE.Color(colHex);
        colors.push(c.r, c.g, c.b, c.r, c.g, c.b);
      }
    }

    if (this.tracerLines) {
      this.scene.remove(this.tracerLines);
      this.tracerLines.geometry.dispose();
      this.tracerLines.material.dispose();
      this.tracerLines = null;
    }

    if (positions.length > 0) {
      const geometry = new THREE.BufferGeometry();
      geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
      geometry.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3));

      const material = new THREE.LineBasicMaterial({
        vertexColors: true,
        transparent: true,
        opacity: 0.65,
        blending: THREE.AdditiveBlending
      });

      this.tracerLines = new THREE.LineSegments(geometry, material);
      this.scene.add(this.tracerLines);
    }
  }

  setRenderMode(mode) {
    this.renderMode = mode;
    document.querySelectorAll('.tool-btn').forEach(btn => btn.classList.remove('active'));

    if (mode === 'solid') {
      document.getElementById('btn-mode-shading').classList.add('active');
    } else if (mode === 'xray') {
      document.getElementById('btn-mode-xray').classList.add('active');
    } else if (mode === 'wireframe') {
      document.getElementById('btn-mode-wireframe').classList.add('active');
    }

    for (const mesh of this.meshObjects) {
      const origColor = mesh.userData.originalColor;
      if (mode === 'wireframe') {
        mesh.material.wireframe = true;
        mesh.material.transparent = false;
        mesh.material.opacity = 1.0;
        mesh.material.depthWrite = true;
      } else if (mode === 'xray') {
        mesh.material.wireframe = false;
        mesh.material.transparent = true;
        mesh.material.opacity = 0.25;
        mesh.material.depthWrite = false;
      } else {
        // Solid
        mesh.material.wireframe = false;
        mesh.material.transparent = mesh.userData.originalTransparent;
        mesh.material.opacity = mesh.userData.originalOpacity;
        mesh.material.depthWrite = true;
      }
    }
  }

  updateClippingPlane() {
    let normal = new THREE.Vector3(0, -1, 0);
    let axisText = 'Y-Axis (Height)';
    if (this.clipAxis === 'x') {
      normal = new THREE.Vector3(-1, 0, 0);
      axisText = 'X-Axis (Lateral)';
    } else if (this.clipAxis === 'z') {
      normal = new THREE.Vector3(0, 0, -1);
      axisText = 'Z-Axis (Depth)';
    }

    this.clipPlane.normal.copy(normal);
    this.clipPlane.constant = this.clipPos;

    document.getElementById('clip-axis-label').textContent = axisText;
    document.getElementById('clip-pos-label').textContent = `${this.clipPos} mm`;

    for (const mesh of this.meshObjects) {
      mesh.material.clippingPlanes = this.clipEnabled ? [this.clipPlane] : [];
    }
  }

  setSubsystemVisibility(subsystem, visible) {
    this.subsystemVisibility[subsystem] = visible;
    for (const mesh of this.meshObjects) {
      if (mesh.userData.meta.subsystem === subsystem) {
        mesh.visible = visible;
      }
    }
    if (this.showTracers) this.updateTracerGeometry();
  }

  soloSubsystem(subsystem) {
    for (const key of Object.keys(this.subsystemVisibility)) {
      const isMatch = (key === subsystem);
      this.subsystemVisibility[key] = isMatch;
      const checkbox = document.getElementById(`sub-check-${key}`);
      if (checkbox) checkbox.checked = isMatch;
      this.setSubsystemVisibility(key, isMatch);
    }
  }

  showAllSubsystems() {
    for (const key of Object.keys(this.subsystemVisibility)) {
      this.subsystemVisibility[key] = true;
      const checkbox = document.getElementById(`sub-check-${key}`);
      if (checkbox) checkbox.checked = true;
      this.setSubsystemVisibility(key, true);
    }
  }

  renderSubsystemList() {
    const listEl = document.getElementById('subsystem-list');
    listEl.innerHTML = '';

    // Count meshes per subsystem
    const counts = {};
    for (const key of Object.keys(SUBSYSTEM_CONFIG)) counts[key] = 0;
    for (const mesh of this.meshObjects) {
      const sub = mesh.userData.meta.subsystem;
      if (counts[sub] !== undefined) counts[sub]++;
    }

    for (const [key, cfg] of Object.entries(SUBSYSTEM_CONFIG)) {
      const item = document.createElement('div');
      item.className = 'subsystem-item';
      item.innerHTML = `
        <label class="subsystem-label-group">
          <input type="checkbox" id="sub-check-${key}" checked>
          <span class="sub-color-pill" style="background: ${cfg.color}"></span>
          <span>${cfg.label}</span>
          <span class="sub-count">(${counts[key]})</span>
        </label>
        <button class="sub-solo-btn" data-sub="${key}">Solo</button>
      `;

      item.querySelector('input').addEventListener('change', (e) => {
        this.setSubsystemVisibility(key, e.target.checked);
      });

      item.querySelector('.sub-solo-btn').addEventListener('click', (e) => {
        e.stopPropagation();
        this.soloSubsystem(key);
      });

      listEl.appendChild(item);
    }
  }

  selectMesh(mesh) {
    if (this.selectedMesh && this.selectedMesh.material) {
      if (this.selectedMesh.material.emissive) {
        this.selectedMesh.material.emissive.setHex(0x000000);
      }
    }

    this.selectedMesh = mesh;
    if (mesh && mesh.material && mesh.material.emissive) {
      mesh.material.emissive.setHex(0x164e63);
    }

    this.updateInspectorHUD(mesh);
  }

  updateInspectorHUD(mesh) {
    if (!mesh) return;
    const meta = mesh.userData.meta;
    const cfg = SUBSYSTEM_CONFIG[meta.subsystem] || { label: 'Mechanical Stage', badgeClass: 'badge-stage', color: '#10b981' };

    document.getElementById('hud-part-name').textContent = meta.name;
    const badge = document.getElementById('hud-subsystem-badge');
    badge.textContent = cfg.label;
    badge.className = `subsystem-badge ${cfg.badgeClass}`;

    document.getElementById('hud-material').textContent = meta.material;
    document.getElementById('hud-role').textContent = meta.kinematic_role;

    if (meta.size) {
      document.getElementById('hud-dimensions').textContent = 
        `${meta.size[0].toFixed(1)} × ${meta.size[1].toFixed(1)} × ${meta.size[2].toFixed(1)} mm`;
    }
    if (meta.center) {
      document.getElementById('hud-center').textContent = 
        `X: ${meta.center[0].toFixed(1)}, Y: ${meta.center[1].toFixed(1)}, Z: ${meta.center[2].toFixed(1)}`;
    }

    // Kinematic mechanical insight text based on component type
    let insight = 'Parametric 3D printable part engineered with captive nut seat and compliant flexure hinges.';
    if (meta.subsystem === 'optics') {
      insight = 'Achromatic tube lens and RMS objective maintain infinite/160mm optical conjugate to minimize chromatic aberrations onto the Sony IMX219 sensor.';
    } else if (meta.subsystem === 'actuators') {
      insight = 'Rotary-to-linear conversion via M3x25 leadscrew with downward Viton elastic band preload, eliminating axial play and backlash.';
    } else if (meta.subsystem === 'illumination') {
      insight = 'Transmitted illumination with adjustable condenser numerical aperture for high-contrast brightfield inspection.';
    } else if (meta.subsystem === 'base_electronics') {
      insight = 'Self-contained modular drawer allows rapid serviceability without disturbing mechanical stage alignment.';
    }
    document.getElementById('hud-engineering-note').innerHTML = `<strong>Mechanical Insight:</strong> ${insight}`;
  }

  setCameraPreset(viewName) {
    const target = new THREE.Vector3(0, 90, 0);
    let camPos = new THREE.Vector3(190, 220, 220);

    if (viewName === 'top') {
      camPos.set(0, 360, 0);
    } else if (viewName === 'front') {
      camPos.set(0, 110, 330);
    } else if (viewName === 'side') {
      camPos.set(330, 110, 0);
    } else if (viewName === 'bottom') {
      camPos.set(0, -180, 220);
      target.set(0, 45, 0);
    } else {
      // Isometric
      camPos.set(190, 220, 220);
    }

    // Animate camera position smoothly
    const startPos = this.camera.position.clone();
    const startTarget = this.controls.target.clone();
    const startTime = performance.now();
    const duration = 600;

    const animateCam = (time) => {
      const elapsed = time - startTime;
      const progress = Math.min(elapsed / duration, 1);
      // Smooth cubic ease out
      const ease = 1 - Math.pow(1 - progress, 3);

      this.camera.position.lerpVectors(startPos, camPos, ease);
      this.controls.target.lerpVectors(startTarget, target, ease);
      this.controls.update();

      if (progress < 1) {
        requestAnimationFrame(animateCam);
      }
    };
    requestAnimationFrame(animateCam);

    document.querySelectorAll('.view-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.view === viewName);
    });
  }

  initUI() {
    // Explode slider
    const slider = document.getElementById('explode-slider');
    slider.addEventListener('input', (e) => {
      this.isAnimatingExplode = false;
      this.updateAnimateButtonUI();
      this.setExplode(parseFloat(e.target.value) / 100);
    });

    // Slider marks
    document.querySelectorAll('.slider-marks .mark').forEach(mark => {
      mark.addEventListener('click', () => {
        const val = parseFloat(mark.dataset.val);
        this.setExplode(val / 100);
      });
    });

    // Play/Pause Explode
    const btnAnimate = document.getElementById('btn-animate-explode');
    btnAnimate.addEventListener('click', () => {
      this.isAnimatingExplode = !this.isAnimatingExplode;
      this.updateAnimateButtonUI();
    });

    // Reset Explode
    document.getElementById('btn-reset-explode').addEventListener('click', () => {
      this.isAnimatingExplode = false;
      this.updateAnimateButtonUI();
      this.setExplode(0);
    });

    // Show All Subsystems
    document.getElementById('btn-show-all').addEventListener('click', () => {
      this.showAllSubsystems();
    });

    // Shading mode buttons
    document.getElementById('btn-mode-shading').addEventListener('click', () => this.setRenderMode('solid'));
    document.getElementById('btn-mode-xray').addEventListener('click', () => this.setRenderMode('xray'));
    document.getElementById('btn-mode-wireframe').addEventListener('click', () => this.setRenderMode('wireframe'));

    // Tracers toggle
    const btnTracers = document.getElementById('btn-mode-tracers');
    btnTracers.addEventListener('click', () => {
      this.showTracers = !this.showTracers;
      btnTracers.classList.toggle('active', this.showTracers);
      this.updateTracerGeometry();
    });

    // Clipping controls
    const clipCheck = document.getElementById('clip-enabled');
    const clipWrap = document.getElementById('clipping-slider-wrap');
    clipCheck.addEventListener('change', (e) => {
      this.clipEnabled = e.target.checked;
      clipWrap.style.display = this.clipEnabled ? 'flex' : 'none';
      this.updateClippingPlane();
    });

    document.querySelectorAll('.axis-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.axis-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        this.clipAxis = btn.dataset.axis;
        this.updateClippingPlane();
      });
    });

    const clipSlider = document.getElementById('clip-slider');
    clipSlider.addEventListener('input', (e) => {
      this.clipPos = parseFloat(e.target.value);
      this.updateClippingPlane();
    });

    // Camera view buttons
    document.querySelectorAll('.view-btn').forEach(btn => {
      btn.addEventListener('click', () => this.setCameraPreset(btn.dataset.view));
    });

    // Turntable Auto-Rotate
    const btnAutoRotate = document.getElementById('btn-autorotate');
    btnAutoRotate.addEventListener('click', () => {
      this.controls.autoRotate = !this.controls.autoRotate;
      btnAutoRotate.classList.toggle('active', this.controls.autoRotate);
    });

    // Reset Camera
    document.getElementById('btn-reset-cam').addEventListener('click', () => {
      this.setCameraPreset('isometric');
    });

    // Fullscreen
    document.getElementById('btn-fullscreen').addEventListener('click', () => {
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => alert(err.message));
      } else {
        document.exitFullscreen();
      }
    });
  }

  updateAnimateButtonUI() {
    const btn = document.getElementById('btn-animate-explode');
    const label = document.getElementById('animate-label');
    if (this.isAnimatingExplode) {
      label.textContent = 'Pause';
      btn.classList.add('active');
    } else {
      label.textContent = 'Play Explode';
      btn.classList.remove('active');
    }
  }

  setupEvents() {
    window.addEventListener('resize', () => {
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
    });

    // Raycast click & hover
    const onPointerMove = (e) => {
      this.mouse.x = (e.clientX / window.innerWidth) * 2 - 1;
      this.mouse.y = -(e.clientY / window.innerHeight) * 2 + 1;
    };

    const onClick = () => {
      this.raycaster.setFromCamera(this.mouse, this.camera);
      const visibleMeshes = this.meshObjects.filter(m => m.visible);
      const intersects = this.raycaster.intersectObjects(visibleMeshes);
      if (intersects.length > 0) {
        this.selectMesh(intersects[0].object);
      }
    };

    window.addEventListener('pointermove', onPointerMove);
    this.renderer.domElement.addEventListener('click', onClick);
  }

  animate() {
    requestAnimationFrame(() => this.animate());

    // Explode playback animation
    if (this.isAnimatingExplode) {
      let nextFactor = this.explodeFactor + 0.007 * this.animDirection;
      if (nextFactor >= 1) {
        nextFactor = 1;
        this.animDirection = -1;
      } else if (nextFactor <= 0) {
        nextFactor = 0;
        this.animDirection = 1;
      }
      this.setExplode(nextFactor);
    }

    // Raycast hover highlight
    if (this.meshObjects.length > 0 && this.renderMode !== 'wireframe') {
      this.raycaster.setFromCamera(this.mouse, this.camera);
      const visibleMeshes = this.meshObjects.filter(m => m.visible);
      const intersects = this.raycaster.intersectObjects(visibleMeshes);

      let hit = intersects.length > 0 ? intersects[0].object : null;

      if (this.hoveredMesh && this.hoveredMesh !== this.selectedMesh) {
        if (this.hoveredMesh.material && this.hoveredMesh.material.emissive) {
          this.hoveredMesh.material.emissive.setHex(0x000000);
        }
      }

      this.hoveredMesh = hit;
      if (hit && hit !== this.selectedMesh && hit.material && hit.material.emissive) {
        hit.material.emissive.setHex(0x083344);
      }
    }

    this.controls.update();
    this.renderer.render(this.scene, this.camera);
  }
}

// Initialize when DOM is ready
window.addEventListener('DOMContentLoaded', () => {
  new ExplodedViewApp();
});
