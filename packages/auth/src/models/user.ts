import z from 'zod'

import { type Role, roleSchema } from '../roles'

export const userSchema = z.object({
  role: roleSchema,
})

export type UserSchema = z.infer<typeof userSchema>

export type User = {
  role: Role
}
