import type { Matrix, Vector3 } from "./math.vector";
import type { DeepImmutable } from "../types";
import { Plane } from "./math.plane";
export class Frustum {
    public static GetPlanes(transform: DeepImmutable<Matrix>): Plane[] {
        const frustumPlanes = [];
        for (let index = 0; index < 6; index++) {
            frustumPlanes.push(new Plane(0.0, 0.0, 0.0, 0.0));
        }
        Frustum.GetPlanesToRef(transform, frustumPlanes);
        return frustumPlanes;
    }
    public static GetNearPlaneToRef(transform: DeepImmutable<Matrix>, frustumPlane: Plane): void {
        const m = transform.m;
        frustumPlane.normal.x = m[3] + m[2];
        frustumPlane.normal.y = m[7] + m[6];
        frustumPlane.normal.z = m[11] + m[10];
        frustumPlane.d = m[15] + m[14];
        frustumPlane.normalize();
    }
    public static GetFarPlaneToRef(transform: DeepImmutable<Matrix>, frustumPlane: Plane): void {
        const m = transform.m;
        frustumPlane.normal.x = m[3] - m[2];
        frustumPlane.normal.y = m[7] - m[6];
        frustumPlane.normal.z = m[11] - m[10];
        frustumPlane.d = m[15] - m[14];
        frustumPlane.normalize();
    }
    public static GetLeftPlaneToRef(transform: DeepImmutable<Matrix>, frustumPlane: Plane): void {
        const m = transform.m;
        frustumPlane.normal.x = m[3] + m[0];
        frustumPlane.normal.y = m[7] + m[4];
        frustumPlane.normal.z = m[11] + m[8];
        frustumPlane.d = m[15] + m[12];
        frustumPlane.normalize();
    }
    public static GetRightPlaneToRef(transform: DeepImmutable<Matrix>, frustumPlane: Plane): void {
        const m = transform.m;
        frustumPlane.normal.x = m[3] - m[0];
        frustumPlane.normal.y = m[7] - m[4];
        frustumPlane.normal.z = m[11] - m[8];
        frustumPlane.d = m[15] - m[12];
        frustumPlane.normalize();
    }
    public static GetTopPlaneToRef(transform: DeepImmutable<Matrix>, frustumPlane: Plane): void {
        const m = transform.m;
        frustumPlane.normal.x = m[3] - m[1];
        frustumPlane.normal.y = m[7] - m[5];
        frustumPlane.normal.z = m[11] - m[9];
        frustumPlane.d = m[15] - m[13];
        frustumPlane.normalize();
    }
    public static GetBottomPlaneToRef(transform: DeepImmutable<Matrix>, frustumPlane: Plane): void {
        const m = transform.m;
        frustumPlane.normal.x = m[3] + m[1];
        frustumPlane.normal.y = m[7] + m[5];
        frustumPlane.normal.z = m[11] + m[9];
        frustumPlane.d = m[15] + m[13];
        frustumPlane.normalize();
    }
    public static GetPlanesToRef(transform: DeepImmutable<Matrix>, frustumPlanes: Plane[]): void {
        // Near
        Frustum.GetNearPlaneToRef(transform, frustumPlanes[0]);
        // Far
        Frustum.GetFarPlaneToRef(transform, frustumPlanes[1]);
        // Left
        Frustum.GetLeftPlaneToRef(transform, frustumPlanes[2]);
        // Right
        Frustum.GetRightPlaneToRef(transform, frustumPlanes[3]);
        // Top
        Frustum.GetTopPlaneToRef(transform, frustumPlanes[4]);
        // Bottom
        Frustum.GetBottomPlaneToRef(transform, frustumPlanes[5]);
    }
    public static IsPointInFrustum(point: Vector3, frustumPlanes: Array<DeepImmutable<Plane>>): boolean {
        for (let i = 0; i < 6; i++) {
            if (frustumPlanes[i].dotCoordinate(point) < 0) {
                return false;
            }
        }
        return true;
    }
}