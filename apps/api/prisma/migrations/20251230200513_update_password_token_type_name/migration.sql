/*
  Warnings:

  - The values [PASSWORD_RECOVERY] on the enum `TokenType` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the column `userId` on the `accounts` table. All the data in the column will be lost.
  - You are about to drop the column `organizationId` on the `invites` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[provider,user_id]` on the table `accounts` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[email,organization_id]` on the table `invites` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[organization_id,user_id]` on the table `members` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `user_id` to the `accounts` table without a default value. This is not possible if the table is not empty.
  - Added the required column `organization_id` to the `invites` table without a default value. This is not possible if the table is not empty.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "TokenType_new" AS ENUM ('PASSWORD_RECOVER');
ALTER TABLE "tokens" ALTER COLUMN "type" TYPE "TokenType_new" USING ("type"::text::"TokenType_new");
ALTER TYPE "TokenType" RENAME TO "TokenType_old";
ALTER TYPE "TokenType_new" RENAME TO "TokenType";
DROP TYPE "public"."TokenType_old";
COMMIT;

-- DropForeignKey
ALTER TABLE "accounts" DROP CONSTRAINT "accounts_userId_fkey";

-- DropForeignKey
ALTER TABLE "invites" DROP CONSTRAINT "invites_organizationId_fkey";

-- DropIndex
DROP INDEX "accounts_provider_userId_key";

-- DropIndex
DROP INDEX "invites_email_organizationId_key";

-- DropIndex
DROP INDEX "members_organization_id_user_id_idx";

-- AlterTable
ALTER TABLE "accounts" DROP COLUMN "userId",
ADD COLUMN     "user_id" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "invites" DROP COLUMN "organizationId",
ADD COLUMN     "organization_id" TEXT NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "accounts_provider_user_id_key" ON "accounts"("provider", "user_id");

-- CreateIndex
CREATE UNIQUE INDEX "invites_email_organization_id_key" ON "invites"("email", "organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "members_organization_id_user_id_key" ON "members"("organization_id", "user_id");

-- AddForeignKey
ALTER TABLE "accounts" ADD CONSTRAINT "accounts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invites" ADD CONSTRAINT "invites_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
