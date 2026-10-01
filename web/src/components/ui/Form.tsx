import { useId, type ComponentProps, type ReactNode } from "react";
import { cn } from "@/lib/cn";
import { Icon, type IconName } from "./Icon";

/* ------------------------------------------------------------------ */
/* Field wrapper                                                       */
/* ------------------------------------------------------------------ */

export function Field({
  label,
  htmlFor,
  help,
  error,
  success,
  children,
  className,
  labelClassName,
  labelAside,
}: {
  label?: ReactNode;
  htmlFor?: string;
  help?: ReactNode;
  error?: ReactNode;
  success?: ReactNode;
  children: ReactNode;
  className?: string;
  labelClassName?: string;
  labelAside?: ReactNode;
}) {
  return (
    <div className={cn("flex min-w-0 flex-col gap-1.5", className)}>
      {label && (
        <div className="flex items-center justify-between gap-2">
          <label htmlFor={htmlFor} className={cn("text-[14px] font-semibold text-ink", labelClassName)}>
            {label}
          </label>
          {labelAside}
        </div>
      )}
      {children}
      {(error || success || help) && (
        <p
          id={htmlFor ? `${htmlFor}-help` : undefined}
          className={cn(
            "text-[12px]",
            error ? "text-danger-fg" : success ? "text-pomme-700" : "text-muted",
          )}
        >
          {error ?? success ?? help}
        </p>
      )}
    </div>
  );
}

const controlBase =
  "w-full rounded-[10px] border-[1.5px] border-line-strong bg-white text-[15px] text-ink transition-[border-color,box-shadow] duration-[120ms] hover:border-stone focus-within:border-pomme-600 focus-within:shadow-[0_0_0_4px_rgba(140,198,63,0.28)]";

/* ------------------------------------------------------------------ */
/* Input                                                               */
/* ------------------------------------------------------------------ */

export interface InputProps extends Omit<ComponentProps<"input">, "size"> {
  label?: ReactNode;
  help?: ReactNode;
  error?: ReactNode;
  success?: ReactNode;
  leadingIcon?: IconName;
  trailingIcon?: IconName;
  trailing?: ReactNode;
  wrapperClassName?: string;
  controlClassName?: string;
  size?: "md" | "sm" | "lg";
  labelAside?: ReactNode;
}

export function Input({
  label,
  help,
  error,
  success,
  leadingIcon,
  trailingIcon,
  trailing,
  id,
  className,
  wrapperClassName,
  controlClassName,
  size = "md",
  labelAside,
  ...rest
}: InputProps) {
  const auto = useId();
  const inputId = id ?? auto;
  const control = (
    <div
      className={cn(
        controlBase,
        "flex items-center gap-2 px-3",
        size === "md" && "h-12",
        size === "sm" && "h-10 text-[14px]",
        size === "lg" && "h-[50px] rounded-md px-3.5 text-[16px]",
        error && "border-danger-fg hover:border-danger-fg focus-within:border-danger-fg focus-within:shadow-[0_0_0_4px_rgba(192,53,43,0.15)]",
        success && "border-pomme-600",
        rest.disabled && "border-line bg-sand text-disabled hover:border-line",
        controlClassName,
      )}
    >
      {leadingIcon && <Icon name={leadingIcon} size={18} className="text-muted" />}
      <input
        id={inputId}
        aria-invalid={error ? true : undefined}
        aria-describedby={error || help || success ? `${inputId}-help` : undefined}
        className={cn(
          "h-full min-w-0 flex-1 border-0 bg-transparent text-inherit outline-none focus-visible:outline-none",
          className,
        )}
        {...rest}
      />
      {trailingIcon && (
        <Icon
          name={trailingIcon}
          size={18}
          className={error ? "text-danger-fg" : success ? "text-pomme-700" : "text-muted"}
        />
      )}
      {trailing}
    </div>
  );
  if (!label && !help && !error && !success) return <div className={wrapperClassName}>{control}</div>;
  return (
    <Field
      label={label}
      htmlFor={inputId}
      help={help}
      error={error}
      success={success}
      className={wrapperClassName}
      labelAside={labelAside}
    >
      {control}
    </Field>
  );
}

/* ------------------------------------------------------------------ */
/* Textarea                                                            */
/* ------------------------------------------------------------------ */

export function Textarea({
  label,
  help,
  error,
  id,
  className,
  wrapperClassName,
  counter,
  ...rest
}: ComponentProps<"textarea"> & {
  label?: ReactNode;
  help?: ReactNode;
  error?: ReactNode;
  wrapperClassName?: string;
  counter?: string;
}) {
  const auto = useId();
  const tid = id ?? auto;
  const el = (
    <textarea
      id={tid}
      aria-invalid={error ? true : undefined}
      className={cn(
        controlBase,
        "block min-h-[96px] resize-y p-3 leading-[22px] outline-none focus:border-pomme-600 focus:shadow-[0_0_0_4px_rgba(140,198,63,0.28)] focus-visible:outline-none",
        error && "border-danger-fg",
        className,
      )}
      {...rest}
    />
  );
  return (
    <Field label={label} htmlFor={tid} help={help} error={error} className={wrapperClassName}>
      {el}
      {counter && <span className="self-end text-[12px] text-muted">{counter}</span>}
    </Field>
  );
}

/* ------------------------------------------------------------------ */
/* Select (native, styled)                                             */
/* ------------------------------------------------------------------ */

export function Select({
  label,
  help,
  id,
  options,
  className,
  wrapperClassName,
  size = "md",
  ...rest
}: Omit<ComponentProps<"select">, "size"> & {
  label?: ReactNode;
  help?: ReactNode;
  options: { value: string; label: string; disabled?: boolean }[];
  wrapperClassName?: string;
  size?: "md" | "sm";
}) {
  const auto = useId();
  const sid = id ?? auto;
  const el = (
    <div className={cn(controlBase, "relative flex items-center", size === "md" ? "h-12" : "h-10 text-[14px]", className)}>
      <select
        id={sid}
        className="h-full w-full appearance-none rounded-[10px] border-0 bg-transparent pr-9 pl-3 font-[inherit] text-inherit outline-none focus-visible:outline-none"
        {...rest}
      >
        {options.map((o) => (
          <option key={o.value} value={o.value} disabled={o.disabled}>
            {o.label}
          </option>
        ))}
      </select>
      <Icon name="chevD" size={18} className="pointer-events-none absolute right-3 text-ink" />
    </div>
  );
  if (!label && !help) return <div className={wrapperClassName}>{el}</div>;
  return (
    <Field label={label} htmlFor={sid} help={help} className={wrapperClassName}>
      {el}
    </Field>
  );
}

/* ------------------------------------------------------------------ */
/* Checkbox & radio (native inputs, custom visuals)                    */
/* ------------------------------------------------------------------ */

export function Checkbox({
  label,
  hint,
  className,
  error,
  size = 20,
  ...rest
}: Omit<ComponentProps<"input">, "type" | "size"> & {
  label?: ReactNode;
  hint?: ReactNode;
  error?: boolean;
  size?: number;
}) {
  return (
    <label
      className={cn(
        "flex min-h-[30px] cursor-pointer items-center gap-2.5 text-[14px]",
        error && "text-danger-fg",
        rest.disabled && "cursor-not-allowed text-disabled",
        className,
      )}
    >
      <span className="relative inline-flex shrink-0" style={{ width: size, height: size }}>
        <input
          type="checkbox"
          className={cn(
            "peer absolute inset-0 m-0 cursor-[inherit] appearance-none rounded-[6px] border-[1.5px] border-stone bg-white",
            "checked:border-0 checked:bg-pomme-500 focus-visible:shadow-[0_0_0_4px_rgba(140,198,63,0.28)] focus-visible:outline-none",
            error && "border-danger-fg",
            "disabled:border-line-strong disabled:bg-line-strong",
          )}
          {...rest}
        />
        <Icon
          name="check"
          size={Math.round(size * 0.7)}
          className="pointer-events-none absolute inset-0 m-auto text-on-primary opacity-0 peer-checked:opacity-100 peer-disabled:text-disabled"
        />
      </span>
      {label && <span className="flex-1">{label}</span>}
      {hint != null && <span className="text-[12px] text-muted">{hint}</span>}
    </label>
  );
}

export function Radio({
  label,
  className,
  ...rest
}: Omit<ComponentProps<"input">, "type"> & { label?: ReactNode }) {
  return (
    <label className={cn("flex min-h-8 cursor-pointer items-center gap-3 text-[15px]", className)}>
      <RadioDot {...rest} />
      {label && <span>{label}</span>}
    </label>
  );
}

/** Radio input only (for cards that contain their own label). */
export function RadioDot({ className, ...rest }: Omit<ComponentProps<"input">, "type">) {
  return (
    <span className={cn("relative inline-flex size-[22px] shrink-0", className)}>
      <input
        type="radio"
        className="peer absolute inset-0 m-0 cursor-pointer appearance-none rounded-full border-[1.5px] border-stone bg-white checked:border-2 checked:border-pomme-600 focus-visible:shadow-[0_0_0_4px_rgba(140,198,63,0.28)] focus-visible:outline-none"
        {...rest}
      />
      <span className="pointer-events-none absolute inset-0 m-auto size-2.5 rounded-full bg-pomme-600 opacity-0 peer-checked:opacity-100" />
    </span>
  );
}

/** Visual-only radio indicator (for button-based choice cards). */
export function RadioIndicator({ checked, tone = "pomme" }: { checked: boolean; tone?: "pomme" | "danger" }) {
  const color = tone === "danger" ? "border-danger-fg" : "border-pomme-600";
  const dot = tone === "danger" ? "bg-danger-fg" : "bg-pomme-600";
  return (
    <span
      aria-hidden
      className={cn(
        "inline-flex size-[22px] shrink-0 items-center justify-center rounded-full bg-white",
        checked ? cn("border-2", color) : "border-[1.5px] border-stone",
      )}
    >
      <span className={cn("size-2.5 rounded-full", checked ? dot : "bg-transparent")} />
    </span>
  );
}

/** Visual-only checkbox indicator (for button-based toggle cards). */
export function CheckIndicator({ checked, size = 20 }: { checked: boolean; size?: number }) {
  return (
    <span
      aria-hidden
      className={cn(
        "inline-flex shrink-0 items-center justify-center rounded-[6px] text-on-primary",
        checked ? "bg-pomme-500" : "border-[1.5px] border-stone bg-white",
      )}
      style={{ width: size, height: size }}
    >
      {checked && <Icon name="check" size={Math.round(size * 0.7)} />}
    </span>
  );
}
