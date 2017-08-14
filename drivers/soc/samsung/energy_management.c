/*
 * Energy Management Driver
 *
 * Copyright (c) 2017, Sonsation <jhson9304@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 */

#include <linux/cpufreq.h>
#include <linux/kernel.h>
#include <linux/mutex.h>
#include <linux/state_notifier.h>

#define SUSPEND_DELAY (5000) // after 5s later suspend

LIST_HEAD(cpufreq_governors);
static struct delayed_work restore_prev;

static int state_notifier_callback(struct notifier_block *this,
				unsigned long event, void *data)
{
	switch (event) {
		case STATE_NOTIFIER_SUSPEND:

                /*
                 * Swithch from intractive to powersave
                 *
                 */
                        queue_delayed_work(system_power_efficient_wq, &restore_prev,
				msecs_to_jiffies(SUSPEND_DELAY));

			break;

		default:

                /*
                 * Swithch from powersave to interactive
                 *
                 */
                        if (delayed_work_pending(&restore_prev))
				cancel_delayed_work_sync(&restore_prev);

                        cpufreq_register_governor(&cpufreq_gov_powersave);

			break;
	}

	return NOTIFY_OK;
}

static struct notifier_block em_notifier_block = {
	.notifier_call = state_notifier_callback,
};

static int em_driver_init(void)
{
       state_register_client(&em_notifier_block);
       return 0;

}
late_initcall(em_driver_init);
